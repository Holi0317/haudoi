import { useSql, sql } from "../../composable/sql";
import { CountSchema } from "../../schemas";

export function useMeta(ctx: DurableObjectState) {
  const conn = useSql(ctx);

  /**
   * Get colocation (airport code) of the current durable object instance.
   *
   * @returns Colocation code, or "unknown" if failed to fetch or parse.
   */
  const getColo = async () => {
    const resp = await fetch("https://www.cloudflare.com/cdn-cgi/trace");
    const body = await resp.text();

    const match = body.match(/^colo=(.+)/m);
    if (match == null) {
      return "unknown";
    }

    return match[1];
  };

  /**
   * Get statistics about this durable object
   */
  const stat = async () => {
    const colo = await getColo();

    const dbSize = ctx.storage.sql.databaseSize;

    const { count } = conn.one(
      CountSchema,
      sql`SELECT COUNT(*) AS count FROM link;`,
    );

    const maxID = conn.one(
      CountSchema,
      sql`SELECT IFNULL(MAX(id), 0) AS count FROM link;`,
    );

    return {
      name: ctx.id.name,
      colo,
      dbSize,
      count,
      maxID: maxID.count,
    };
  };

  return {
    stat,
  };
}
