import { DurableObject } from "cloudflare:workers";
import * as z from "zod";
import type { DBMigration } from "../composable/db_migration";
import { useDBMigration } from "../composable/db_migration";
import { sql, useSql } from "../composable/sql";
import { decodeCursor } from "../composable/cursor";
import type {
  EditOpSchema,
  LinkInsertItem,
  SearchQuerySchema,
  TagItem,
} from "../schemas";
import { LinkItemSchema, TagItemSchema, TagInputSchema } from "../schemas";
import { stringify } from "@std/csv";

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
  {
    name: "20260131-create-tag",
    script: sql`
-- Tag table: stores user's tags with case-insensitive unique names
CREATE TABLE tag (
  id integer PRIMARY KEY AUTOINCREMENT,
  -- Tag name, stored in original case but unique when compared case-insensitively
  name text NOT NULL CHECK (length(name) > 0 AND length(name) <= 64),
  -- Tag color as hex string (e.g., #FF5733). Validation done at application layer.
  color text NOT NULL CHECK (length(color) = 7 AND color GLOB '#*')
);

-- Case-insensitive unique index on tag name
CREATE UNIQUE INDEX idx_tag_name_lower ON tag(lower(name));

-- Junction table: links tags to links by numeric id
CREATE TABLE link_tag (
  link_id integer NOT NULL REFERENCES link(id) ON DELETE CASCADE,
  tag_id integer NOT NULL REFERENCES tag(id) ON DELETE CASCADE,
  PRIMARY KEY (link_id, tag_id)
);

-- Index for efficient lookup of links by tag
CREATE INDEX idx_link_tag_tag_id ON link_tag(tag_id);
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
        case "add_tag":
          // Use INSERT OR IGNORE to silently handle duplicate link-tag pairs
          this.conn.void_(
            sql`INSERT OR IGNORE INTO link_tag (link_id, tag_id) VALUES (${op.id}, ${op.tagId})`,
          );
          break;
        case "remove_tag":
          this.conn.void_(
            sql`DELETE FROM link_tag WHERE link_id = ${op.id} AND tag_id = ${op.tagId}`,
          );
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

  public search(param: z.output<typeof SearchQuerySchema>) {
    const query = param.query || "";

    const cursor = decodeCursor(param.cursor);

    // For text search (param.query):
    // Was using LIKE but got "LIKE or GLOB pattern too complex" error on large search string.
    // Tried fts5 but that isn't what we want. We actually want substring search here, not token
    // search. Like, I wanna see "github" for all links stored in github.
    // Currently settling on instr + lower method for case-insensitive substring search.
    // The lower function isn't foolproof for all languages but should be fine for most cases.

    // Tag filter join - only join link_tag if filtering by tag
    const tagJoin =
      param.tag != null
        ? sql`INNER JOIN link_tag ON link.id = link_tag.link_id AND link_tag.tag_id = ${param.tag}`
        : sql``;

    const frag = sql`
  FROM link
  ${tagJoin}
  WHERE 1=1
    AND (${query} = ''
      OR instr(lower(title), lower(${query})) != 0
      OR instr(lower(url), lower(${query})) != 0
      OR instr(lower(note), lower(${query})) != 0
    )
    AND (${param.archive ?? null} IS NULL OR ${Number(param.archive)} = link.archive)
    AND (${param.favorite ?? null} IS NULL OR ${Number(param.favorite)} = link.favorite)
`;

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
      sql`SELECT link.*
  ${frag}
  AND (${cursorCond})
ORDER BY created_at ${dir}, id ${dir}
LIMIT ${param.limit + 1}`,
    );

    const items = itemsPlus.slice(0, param.limit);
    const hasMore = itemsPlus.length > param.limit;

    // If includeTags is true, fetch tags for returned items
    let itemsWithTags: Array<
      z.output<typeof LinkItemSchema> & { tags?: number[] }
    > = items;
    if (param.includeTags && items.length > 0) {
      const linkIds = items.map((item) => item.id);
      const tagsMap = this.getTagsForLinks(linkIds);
      itemsWithTags = items.map((item) => ({
        ...item,
        tags: tagsMap.get(item.id) ?? [],
      }));
    }

    return {
      /**
       * Total number of items satisfying the filter, exclude pagination.
       */
      count,
      /**
       * Paginated items matching the filter. Length of this array will be <=
       * limit parameter.
       */
      items: itemsWithTags,
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

  // ==================== Tag CRUD Operations ====================

  /**
   * Create a new tag. Returns the created tag.
   * Tag names are case-insensitive unique.
   * Returns null if a tag with the same name (case-insensitive) already exists.
   */
  public createTag(input: z.input<typeof TagInputSchema>): TagItem | null {
    const parsed = TagInputSchema.parse(input);

    try {
      const result = this.conn.one(
        TagItemSchema,
        sql`INSERT INTO tag (name, color) VALUES (${parsed.name}, ${parsed.color}) RETURNING *`,
      );

      return result;
    } catch (error) {
      // Check for unique constraint violation (case-insensitive duplicate name)
      if (
        error instanceof Error &&
        error.message.includes("UNIQUE constraint failed")
      ) {
        return null;
      }
      throw error;
    }
  }

  /**
   * List all tags.
   */
  public listTags(): TagItem[] {
    return this.conn.any(TagItemSchema, sql`SELECT * FROM tag ORDER BY id ASC`);
  }

  /**
   * Get a single tag by ID.
   */
  public getTag(id: number): TagItem | null {
    return this.conn.maybeOne(
      TagItemSchema,
      sql`SELECT * FROM tag WHERE id = ${id}`,
    );
  }

  /**
   * Update a tag. Returns an object with:
   * - tag: the updated tag if successful, null if not found or duplicate name
   * - error: 'not_found' if tag doesn't exist, 'duplicate' if name conflicts, undefined if successful
   */
  public updateTag(
    id: number,
    input: { name?: string; color?: string },
  ): { tag: TagItem | null; error?: "not_found" | "duplicate" } {
    const existing = this.getTag(id);
    if (existing == null) {
      return { tag: null, error: "not_found" };
    }

    const name = input.name ?? existing.name;
    const color = input.color ?? existing.color;

    try {
      this.conn.void_(
        sql`UPDATE tag SET name = ${name}, color = ${color} WHERE id = ${id}`,
      );

      return { tag: this.getTag(id) };
    } catch (error) {
      // Check for unique constraint violation (case-insensitive duplicate name)
      if (
        error instanceof Error &&
        error.message.includes("UNIQUE constraint failed")
      ) {
        return { tag: null, error: "duplicate" };
      }
      throw error;
    }
  }

  /**
   * Delete a tag by ID. Returns true if deleted, false if not found.
   * When a tag is deleted, all link-tag associations are automatically removed (CASCADE).
   */
  public deleteTag(id: number): boolean {
    const existing = this.getTag(id);
    if (existing == null) {
      return false;
    }

    this.conn.void_(sql`DELETE FROM tag WHERE id = ${id}`);
    return true;
  }

  /**
   * Get tag IDs for a specific link.
   */
  public getTagsForLink(linkId: number): number[] {
    const result = this.conn.any(
      z.strictObject({ tag_id: z.number() }),
      sql`SELECT tag_id FROM link_tag WHERE link_id = ${linkId}`,
    );

    return result.map((r) => r.tag_id);
  }

  /**
   * Get tags for multiple links at once.
   * Returns a map of link ID to array of tag IDs.
   */
  public getTagsForLinks(linkIds: number[]): Map<number, number[]> {
    if (linkIds.length === 0) {
      return new Map();
    }

    const result = this.conn.any(
      z.strictObject({ link_id: z.number(), tag_id: z.number() }),
      sql`SELECT link_id, tag_id FROM link_tag WHERE link_id IN (${sql.join(linkIds.map((id) => sql`${id}`))})`,
    );

    const map = new Map<number, number[]>();
    for (const linkId of linkIds) {
      map.set(linkId, []);
    }
    for (const r of result) {
      map.get(r.link_id)?.push(r.tag_id);
    }

    return map;
  }
}
