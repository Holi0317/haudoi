import { DurableObject } from "cloudflare:workers";
import * as z from "zod";
import type { DBMigration } from "../composable/db_migration";
import { useDBMigration } from "../composable/db_migration";
import { sql, useSql } from "../composable/sql";
import { decodeCursor } from "../composable/cursor";
import type { EditOpSchema, LinkInsertItem, SearchQueryType } from "../schemas";
import { LinkItemSchema } from "../schemas";
import { stringify } from "@std/csv";
import { matchersToSql, type Matcher } from "@haudoi/dsl";

const migrations: DBMigration[] = [
  {
    name: "20250610-create-link",
    script: sql`
CREATE TABLE link (
  -- ID/PK of the link. This is a tie breaker for links with same created_at timestamp.
  -- On conflict of URL, we will replace (delete and insert) the row and bump ID.
  id integer PRIMARY KEY AUTOINCREMENT,

  -- Title of the link's HTML page.
  -- If title wasn't available, this will empty string.
  -- WARNING: Title can be used for XSS. Remember to escape before rendering
  title text NOT NULL CHECK (length(title) < 512),
  -- URL of the link.
  url text NOT NULL UNIQUE
    CHECK (url like 'http://%' OR url like 'https://%')
    CHECK (length(url) < 512),
  -- Boolean. Favorite or not.
  favorite integer NOT NULL
    CHECK (favorite = 0 OR favorite = 1)
    DEFAULT FALSE,
  -- Boolean. Archived or not.
  archive integer NOT NULL
    CHECK (archive = 0 OR archive = 1)
    DEFAULT FALSE,
  -- Insert timestamp in epoch milliseconds.
  created_at integer NOT NULL DEFAULT (unixepoch('now', 'subsec') * 1000)
);

CREATE INDEX idx_link_favorite ON link(favorite);
CREATE INDEX idx_link_archive ON link(archive);
`,
  },
  {
    name: "20250612-add-note-column",
    script: sql`
ALTER TABLE link ADD COLUMN note text NOT NULL DEFAULT '' CHECK (length(note) <= 4096);
`,
  },
  {
    name: "20251218-idx-created-at",
    script: sql`
CREATE INDEX idx_link_created_at_sort ON link(created_at DESC, id DESC);
`,
  },
];

const IDSchema = z.strictObject({
  id: z.number(),
});

const CountSchema = z.strictObject({
  count: z.number(),
});

export class StorageDO extends DurableObject<CloudflareBindings> {
  private readonly conn: ReturnType<typeof useSql>;

  public constructor(ctx: DurableObjectState, env: CloudflareBindings) {
    super(ctx, env);
    this.conn = useSql(ctx);

    const { run } = useDBMigration(ctx);
    run(migrations);
  }

  /**
   * Get statistics about this durable object
   */
  public async stat() {
    const colo = await this.getColo();

    const dbSize = this.ctx.storage.sql.databaseSize;

    const { count } = this.conn.one(
      CountSchema,
      sql`SELECT COUNT(*) AS count FROM link;`,
    );

    const maxID = this.conn.one(
      CountSchema,
      sql`SELECT IFNULL(MAX(id), 0) AS count FROM link;`,
    );

    return {
      name: this.ctx.id.name,
      colo,
      dbSize,
      count,
      maxID: maxID.count,
    };
  }

  private async getColo() {
    const resp = await fetch("https://www.cloudflare.com/cdn-cgi/trace");
    const body = await resp.text();

    const match = body.match(/^colo=(.+)/m);
    if (match == null) {
      return "unknown";
    }

    return match[1];
  }

  /**
   * Vacuum underlying SQLite database
   */
  public async vacuum() {
    this.conn.void_(sql`PRAGMA optimize`);
  }

  /**
   * Deallocate this durable object and delete all stored data
   *
   * Technically we only truncate the link table here. The DO instance
   * will still exist and cost us small amount of fee.
   *
   * Doing `storage.deleteAll()` will cause subsequent call to `stats` fail.
   * That resets the state and will recreate the DO with migration on next wake.
   * It's just better to keep the DO instance around.
   */
  public async deallocate() {
    this.conn.void_(sql`TRUNCATE link;`);
  }

  /**
   * Insert given links to database
   */
  public insert(links: LinkInsertItem[]) {
    // Collect min/max ID for return value. Assuming:
    // 1. ID are always increasing (curtesy of AUTOINCREMENT)
    // 2. There isn't any concurrent insert happening when we start inserting.
    //    This is guaranteed by DO concurrency model.
    //
    // If user is trying to insert the same URL in the same transaction, some ID
    // will get replaced.
    //
    // The only reliable way to detect duplication is to query inserted entities
    // after insert with `OR REPLACE`. Which we will do by selecting ID range.

    let minID: number | null = null;
    let maxID: number | null = null;

    for (const link of links) {
      const item = this.conn.one(
        IDSchema,
        sql`INSERT OR REPLACE INTO link (title, url, archive, favorite, note, created_at)
VALUES (${link.title}, ${link.url}, ${Number(link.archive)}, ${Number(link.favorite)}, ${link.note}, ${link.created_at ?? sql`(unixepoch('now', 'subsec') * 1000)`})
RETURNING id;`,
      );

      if (minID == null) {
        minID = item.id;
      }

      maxID = item.id;
    }

    // FIXME: Return per-url insert result back to client. Need some way to
    // indicate there was a duplication/replacement on insert process.

    // No insert happened. Probably `links` parameter is empty array.
    if (minID == null || maxID == null) {
      return [];
    }

    return this.conn.many(
      LinkItemSchema,
      sql`SELECT *
FROM link
WHERE id >= ${minID} AND id <= ${maxID}
ORDER BY id ASC;
    `,
    );
  }

  public edit(ops: Array<z.output<typeof EditOpSchema>>) {
    for (const op of ops) {
      switch (op.op) {
        case "insert": {
          throw new Error(
            "Insert operation not supported in edit method. Use insert method instead.",
          );
        }
        case "set_bool": {
          const column =
            op.field === "archive"
              ? sql.ident("archive")
              : sql.ident("favorite");
          this.conn.void_(
            sql`UPDATE link SET ${column} = ${Number(op.value)} WHERE id = ${op.id}`,
          );
          break;
        }
        case "set_string": {
          this.conn.void_(
            sql`UPDATE link SET note = ${op.value} WHERE id = ${op.id}`,
          );
          break;
        }
        case "delete":
          this.conn.void_(sql`DELETE FROM link WHERE id = ${op.id}`);
          break;
      }
    }
  }

  public get(id: number) {
    return this.conn.maybeOne(
      LinkItemSchema,
      sql`SELECT * FROM link WHERE id = ${id}`,
    );
  }

  public search(param: Omit<SearchQueryType, "query">, matchers: Matcher[]) {
    const cursor = decodeCursor(param.cursor);

    const matchersSql = matchersToSql(matchers, ["l.title", "l.url", "l.note"]);

    const frag = sql`FROM link AS l WHERE ${matchersSql}`;

    const dir =
      param.order === "created_at_asc" ? sql.raw("asc") : sql.raw("desc");
    const comp = param.order === "created_at_asc" ? sql.raw(">") : sql.raw("<");

    const cursorCond =
      cursor == null
        ? sql`1=1`
        : sql`created_at ${comp} ${cursor.created_at} OR (created_at = ${cursor.created_at} AND id ${comp} ${cursor.id})`;

    const { count } = this.conn.one(
      CountSchema,
      sql`SELECT COUNT(*) AS count ${frag}`,
    );

    const itemsPlus = this.conn.any(
      LinkItemSchema,
      sql`SELECT * ${frag}
  AND (${cursorCond})
ORDER BY created_at ${dir}, id ${dir}
LIMIT ${param.limit + 1}`,
    );

    const items = itemsPlus.slice(0, param.limit);
    const hasMore = itemsPlus.length > param.limit;

    return {
      /**
       * Total number of items satisfying the filter, exclude pagination.
       */
      count,
      /**
       * Paginated items matching the filter. Length of this array will be <=
       * limit parameter.
       */
      items,
      /**
       * If true, this query can continue paginate.
       */
      hasMore,
    };
  }

  /**
   * Export all stored links as csv
   */
  public async export_() {
    // This loads all items into memory. Might need to test on large database
    // under worker constraint.
    const items = this.conn.any(
      LinkItemSchema,
      sql`SELECT * FROM link ORDER BY id ASC`,
    );

    const columns = LinkItemSchema.keyof().options;

    return stringify(items, { columns });
  }
}
