import type * as z from "zod";
import { useSql, sql } from "../../composable/sql";
import { CountSchema, IDSchema, LinkItemSchema } from "../../schemas";
import type {
  EditOpSchema,
  LinkInsertItem,
  SearchQueryType,
} from "../../schemas";
import type { Matcher } from "@haudoi/dsl";
import { matchersToSql } from "@haudoi/dsl";
import { decodeCursor } from "../../composable/cursor";

export function useLink(ctx: DurableObjectState) {
  const conn = useSql(ctx);

  /**
   * Get link item by ID. Returns null if not found.
   */
  const get = (id: number) => {
    return conn.maybeOne(
      LinkItemSchema,
      sql`SELECT * FROM link WHERE id = ${id}`,
    );
  };

  /**
   * Insert given links to database
   */
  const insert = (links: LinkInsertItem[]) => {
    // Collect min/max ID for return value. Assuming:
    // 1. ID are always increasing (courtesy of AUTOINCREMENT)
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
      const item = conn.one(
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

    return conn.many(
      LinkItemSchema,
      sql`SELECT *
FROM link
WHERE id >= ${minID} AND id <= ${maxID}
ORDER BY id ASC;
    `,
    );
  };

  /**
   * Apply given edit operations to database
   *
   * @see EditOpSchema for supported edit operations
   */
  const edit = async (ops: Array<z.output<typeof EditOpSchema>>) => {
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
          conn.void_(
            sql`UPDATE link SET ${column} = ${Number(op.value)} WHERE id = ${op.id}`,
          );
          break;
        }
        case "set_string": {
          conn.void_(
            sql`UPDATE link SET note = ${op.value} WHERE id = ${op.id}`,
          );
          break;
        }
        case "delete":
          conn.void_(sql`DELETE FROM link WHERE id = ${op.id}`);
          break;
      }
    }
  };

  /**
   * Search stored links with given query and matchers. Returns matched items.
   */
  const search = (
    param: Omit<SearchQueryType, "query">,
    matchers: Matcher[],
  ) => {
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

    const { count } = conn.one(
      CountSchema,
      sql`SELECT COUNT(*) AS count ${frag}`,
    );

    const itemsPlus = conn.any(
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
  };

  return {
    get,
    insert,
    edit,
    search,
  };
}
