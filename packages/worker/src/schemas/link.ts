import * as z from "zod";
import * as zu from "../zod-utils";
import type { TagItem } from "./tags";

/**
 * Schema for link item stored in database.
 */
export const LinkItemSchema = z.strictObject({
  id: z.number(),
  title: z.string(),
  url: z.string(),
  favorite: zu.sqlBool(),
  archive: zu.sqlBool(),
  created_at: zu.unixEpochMs(),
  note: z.string(),
});

/**
 * Type for link item stored in database.
 */
export type LinkItem = z.output<typeof LinkItemSchema>;

/**
 * Type for link item returned from API, including associated tags.
 */
export type LinkItemWithTags = LinkItem & {
  tags: TagItem[];
};
