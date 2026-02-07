import * as z from "zod";
import * as zu from "../zod-utils";

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
