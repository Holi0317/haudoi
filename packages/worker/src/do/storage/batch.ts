import { stringify } from "@std/csv";
import { sql, useSql } from "../../composable/sql";
import { LinkItemSchema } from "../../schemas";

export function useBatch(ctx: DurableObjectState) {
  const conn = useSql(ctx);

  /**
   * Export all stored links as csv
   */
  const export_ = () => {
    // This loads all items into memory. Might need to test on large database
    // under worker constraint.
    const items = conn.any(
      LinkItemSchema,
      sql`SELECT * FROM link ORDER BY id ASC`,
    );

    const columns = LinkItemSchema.keyof().options;

    return stringify(items, { columns });
  };

  return { export_ };
}
