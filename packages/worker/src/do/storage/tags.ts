import * as z from "zod";
import { sql, useSql } from "../../composable/sql";
import type {
  TagCreateSchema,
  TagUpdateSchema,
  LinkItemSchema,
  TagItem,
} from "../../schemas";
import { TagItemSchema } from "../../schemas";

const LinkTagRowSchema = z.strictObject({
  link_id: z.number(),
  tag_id: z.number(),
});

type TagInfo = Omit<TagItem, "created_at">;

export function useTag(ctx: DurableObjectState) {
  const conn = useSql(ctx);

  const attachTags = (items: Array<z.output<typeof LinkItemSchema>>) => {
    if (items.length === 0) {
      return items.map((item) => ({ ...item, tags: [] }));
    }

    const linkIds = items.map((item) => item.id);

    const linkTags = conn.any(
      LinkTagRowSchema,
      sql`SELECT link_id, tag_id
FROM link_tag
WHERE link_id IN ${sql.in(linkIds)};`,
    );

    const tagIds = [...new Set(linkTags.map((row) => row.tag_id))];
    if (tagIds.length === 0) {
      return items.map((item) => ({ ...item, tags: [] }));
    }

    const tags = conn.any(
      TagItemSchema,
      sql`SELECT * FROM tag
WHERE id IN ${sql.in(tagIds)};`,
    );

    const tagsById = new Map<number, TagInfo>(
      tags.map((tag) => [
        tag.id,
        { id: tag.id, name: tag.name, emoji: tag.emoji, color: tag.color },
      ]),
    );

    const tagsByLinkId = new Map<number, TagInfo[]>();

    for (const row of linkTags) {
      const tag = tagsById.get(row.tag_id);
      if (tag == null) {
        continue;
      }

      const list = tagsByLinkId.get(row.link_id);
      if (list == null) {
        tagsByLinkId.set(row.link_id, [tag]);
        continue;
      }

      list.push(tag);
    }

    const tagNameCollator = new Intl.Collator(undefined, {
      sensitivity: "base",
    });

    return items.map((item) => {
      const tagsForItem = tagsByLinkId.get(item.id) ?? [];
      const tagsSorted = [...tagsForItem].sort((a, b) => {
        const nameComp = tagNameCollator.compare(a.name, b.name);
        if (nameComp !== 0) {
          return nameComp;
        }

        return a.id - b.id;
      });

      return {
        ...item,
        tags: tagsSorted,
      };
    });
  };

  const list = () => {
    return conn.any(
      TagItemSchema,
      sql`SELECT * FROM tag
ORDER BY lower(name) ASC, id ASC;`,
    );
  };

  const create = (input: z.output<typeof TagCreateSchema>) => {
    const tag = conn.one(
      TagItemSchema,
      sql`INSERT INTO tag (name, color, emoji)
VALUES (${input.name}, ${input.color}, ${input.emoji ?? ""})
ON CONFLICT DO UPDATE
  SET name = name -- Dummy update to trigger RETURNING of existing row
RETURNING *;`,
    );

    return tag;
  };

  const update = (id: number, input: z.output<typeof TagUpdateSchema>) => {
    const tag = conn.maybeOne(
      TagItemSchema,
      sql`SELECT * FROM tag WHERE id = ${id};`,
    );

    if (tag == null) {
      return null;
    }

    if (input.name != null) {
      conn.void_(sql`UPDATE tag SET name = ${input.name} WHERE id = ${id}`);
    }

    if (input.color != null) {
      conn.void_(sql`UPDATE tag SET color = ${input.color} WHERE id = ${id}`);
    }

    if (input.emoji != null) {
      conn.void_(sql`UPDATE tag SET emoji = ${input.emoji} WHERE id = ${id}`);
    }

    return conn.one(TagItemSchema, sql`SELECT * FROM tag WHERE id = ${id};`);
  };

  const deleteTag = (id: number) => {
    conn.void_(sql`DELETE FROM tag WHERE id = ${id};`);
  };

  return {
    attachTags,
    list,
    create,
    update,
    deleteTag,
  };
}
