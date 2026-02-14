import { stringify } from "@std/csv";
import { sql, useSql } from "../../composable/sql";
import { LinkItemSchema } from "../../schemas";
import { useTag } from "./tags";

export function useBatch(ctx: DurableObjectState) {
  const conn = useSql(ctx);
  const { attachTags } = useTag(ctx);

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
    const itemsWithTags = attachTags(items);
    const exportItems = itemsWithTags.map(({ tags, ...item }) => ({
      ...item,
      tags: tags.map((tag) => tag.name).join(","),
    }));

    return stringify(exportItems, {
      columns: [...LinkItemSchema.keyof().options, "tags"],
    });
  };

  return { export_ };
}
