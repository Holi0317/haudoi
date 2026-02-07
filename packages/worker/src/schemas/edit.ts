import * as z from "zod";
import * as zu from "../zod-utils";
import { MAX_EDIT_OPS } from "../constants";

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
