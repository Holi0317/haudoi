import * as z from "zod";
import * as zu from "../zod-utils";

/**
 * Schema for tag name.
 */
export const TagNameSchema = z.string().min(1).max(64).trim();

/**
 * Schema for tag color. Stored as a string as hex (e.g. #RRGGBB).
 *
 * Note: This schema enforces lowercase letters. Value can be uppercase but will be transformed to lowercase after validation.
 */
export const TagColorSchema = z
  .string()
  .length(7)
  .toLowerCase()
  .regex(/^#[0-9a-f]{6}$/i);

/**
 * Schema for tag emoji.
 *
 * Character count is based on Unicode grapheme clusters, which means it counts user-perceived characters.
 * This allows for emojis that are composed of multiple code points (like family emojis or emojis with skin tone modifiers) to be counted as a single character.
 * The maximum of 8 characters is chosen to allow for reasonably complex emojis while preventing excessively long strings.
 *
 * Ok I actually want to force only 1 emoji character but giving a safe upper bound of 8 just in case.
 *
 * If this is an empty string, tag does not have an emoji.
 */
export const TagEmojiSchema = z.union([z.literal(""), z.emoji().max(8)]);

/**
 * Schema for tag item stored in database.
 */
export const TagItemSchema = z.strictObject({
  id: z.number(),
  name: TagNameSchema,
  color: TagColorSchema,
  emoji: TagEmojiSchema,
  created_at: zu.unixEpochMs(),
});

/**
 * Type for tag item stored in database.
 */
export type TagItem = z.output<typeof TagItemSchema>;

/**
 * Schema for creating a tag.
 */
export const TagCreateSchema = z.object({
  name: TagNameSchema,
  color: TagColorSchema,
  emoji: TagEmojiSchema.default(""),
});

/**
 * Schema for updating a tag.
 */
export const TagUpdateSchema = z
  .object({
    name: TagNameSchema.optional(),
    color: TagColorSchema.optional(),
    emoji: TagEmojiSchema.optional(),
  })
  .refine(
    (value) => value.name != null || value.color != null || value.emoji != null,
    {
      message: "At least one field is required",
    },
  );

/**
 * Schema for setting tags on a link.
 */
export const LinkTagSetSchema = z.object({
  tag_ids: z.array(z.number().int().positive()).max(100).default([]),
});
