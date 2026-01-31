/**
 * Zod / API schema for CRUD API.
 *
 * Both hono and DurableObject needs to use this. Not sure where else to put
 * them so throwing all of them here for now.
 *
 * @module
 */

import * as z from "zod";
import * as zu from "./zod-utils";
import { MAX_EDIT_OPS } from "./constants";

/**
 * Simple id coerce into a number schema.
 */
export const IDStringSchema = z.object({
  id: z.coerce.number(),
});

/**
 * Query on searching API
 */
export const SearchQuerySchema = z.object({
  query: z
    .string()
    .nullish()
    .meta({
      description: `Search query. This will search both title and url.
      null / undefined / empty string will all be treated as disable search filter.`,
    }),
  cursor: z
    .string()
    .nullish()
    .meta({
      description: `Cursor for pagination.
      null / undefined / empty string will be treated as noop.
      Note the client must keep other search parameters the same when paginating.`,
    }),
  archive: zu.queryBool().meta({
    description: `Archive filter. Undefined means disable filter. Boolean means the item must be archived or not archived.`,
  }),
  favorite: zu.queryBool().meta({
    description: `Favorite filter.
      Undefined means disable filter. Boolean means the item must be favorited or not favorited.`,
  }),
  tag: z.coerce.number().optional().meta({
    description: `Tag filter. If provided, only return links with this tag ID.`,
  }),
  includeTags: zu.queryBool().meta({
    description: `If true, include tag IDs array for each link in the response.`,
  }),
  limit: z.coerce.number().min(1).max(300).default(30).meta({
    description: `Limit items to return.`,
  }),
  order: z
    .literal(["created_at_asc", "created_at_desc"])
    .default("created_at_desc")
    .meta({
      description: "Order in result. Can only sort by created_at",
    }),
});

/**
 * Schema for insert object from client.
 *
 * Client actually ships this inside EditOpSchema. However in worker code
 * we handle insert separately and having a separate type makes it easier for
 * reference.
 */
export const InsertSchema = z.object({
  title: z.string().nullish(),
  url: zu.httpUrl(),
  created_at: zu.unixEpochMs().optional(),
  archive: z.boolean().default(false),
  favorite: z.boolean().default(false),
  note: z.string().max(4096).default(""),
});

/**
 * Schema for insert object with title resolved. Actual type accepted by insert in
 * durable object.
 *
 * Basically the same as {@link InsertSchema}, however the title needs to be
 * resolved and present (not nullish).
 * Use `processInsert` to convert from InsertSchema to this type.
 */
export const InsertLinkItemSchema = InsertSchema.extend({
  title: z.string().max(512),
});

/**
 * @see InsertLinkItemSchema
 */
export type LinkInsertItem = z.output<typeof InsertLinkItemSchema>;

/**
 * A single edit operation for stored links.
 */
export const EditOpSchema = z.discriminatedUnion("op", [
  z.object({
    op: z.literal("insert"),
    ...InsertSchema.shape,
  }),
  z.object({
    op: z.literal("set_bool"),
    id: z.number(),
    field: z.literal(["archive", "favorite"]),
    value: z.boolean(),
  }),
  z.object({
    op: z.literal("set_string"),
    id: z.number(),
    field: z.literal(["note"]),
    value: z.string(),
  }),
  z.object({ op: z.literal("delete"), id: z.number() }),
  // Tag operations on links
  z.object({
    op: z.literal("add_tag"),
    id: z.number(), // link id
    tagId: z.number(),
  }),
  z.object({
    op: z.literal("remove_tag"),
    id: z.number(), // link id
    tagId: z.number(),
  }),
]);

/**
 * JSON body for editing stored links or inserting new items
 */
export const EditBodySchema = z.object({
  op: z
    .array(EditOpSchema)
    .min(1, { error: "At least one operation is required" })
    .max(MAX_EDIT_OPS, {
      error: `At most ${MAX_EDIT_OPS} operations per request`,
    }),
});

/**
 * Query parameters for image preview endpoint
 */
export const ImageQuerySchema = z.object({
  url: zu.httpUrl(),
  type: z.enum(["social", "favicon"]).default("social").meta({
    description: `Type of image to fetch. 'social' fetches og:image/twitter:image, 'favicon' fetches site favicon.`,
  }),
  dpr: z.coerce.number().positive().optional(),
  width: z.coerce.number().positive().optional(),
  height: z.coerce.number().positive().optional(),
});

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
 * Schema for tag item stored in database.
 * Tags are case-insensitive unique per user and have a color for UI display.
 */
export const TagItemSchema = z.strictObject({
  id: z.number(),
  name: z.string(),
  color: z.string(),
});

/**
 * Type for tag item stored in database.
 */
export type TagItem = z.output<typeof TagItemSchema>;

/**
 * Schema for creating/updating a tag.
 */
export const TagInputSchema = z.object({
  name: z.string().min(1).max(64),
  color: z.string().regex(/^#[0-9a-fA-F]{6}$/, {
    message: "Color must be a valid hex color (e.g., #FF5733)",
  }),
});

/**
 * Schema for updating a tag (partial).
 */
export const TagUpdateSchema = TagInputSchema.partial();

/**
 * Schema for link item with tags included.
 */
export const LinkItemWithTagsSchema = LinkItemSchema.extend({
  tags: z.array(z.number()),
});

/**
 * Type for link item with tags.
 */
export type LinkItemWithTags = z.output<typeof LinkItemWithTagsSchema>;

/**
 * Info/statistics about completed import
 */
export const ImportCompletedSchema = z.object({
  /**
   * When the import completed
   */
  completedAt: zu.unixEpochMs(),
  /**
   * Number of processed rows from source file
   */
  processed: z.number(),
  /**
   * Number of inserted rows. This can be less than processed due to deduplication
   */
  inserted: z.number(),
  /**
   * Errors encountered during import
   */
  errors: z.array(z.string()),
});

/**
 * Schema for import status in storage DO
 */
export const ImportStatusSchema = z.object({
  /**
   * ID for raw file upload stored in KV
   */
  rawId: z.string(),

  /**
   * ID for the import workflow.
   *
   * Querying this workflow ID might give empty result if the workflow log
   * has already been purged.
   */
  workflowId: z.string(),

  /**
   * When the import started
   */
  startedAt: zu.unixEpochMs(),

  /**
   * Complete status. Null if the import workflow is still in progress.
   */
  completed: ImportCompletedSchema.nullable(),
});
