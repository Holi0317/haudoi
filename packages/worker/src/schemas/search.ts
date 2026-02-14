import * as z from "zod";
import { MAX_SEARCH_ITEMS } from "../constants";

/**
 * Query on searching API
 */
export const SearchQuerySchema = z.object({
  query: z.string().default("").meta({
    description: `DSL search query string. Empty string means no filters applied. See repository README.md for documentation.`,
  }),
  cursor: z
    .string()
    .nullish()
    .meta({
      description: `Cursor for pagination.
      null / undefined / empty string will be treated as noop.
      Note the client must keep other search parameters the same when paginating.`,
    }),
  limit: z.coerce.number().min(1).max(MAX_SEARCH_ITEMS).default(30).meta({
    description: `Limit items to return.`,
  }),
  order: z
    .literal(["created_at_asc", "created_at_desc"])
    .default("created_at_desc")
    .meta({
      description: "Order in result. Can only sort by created_at",
    }),
});

export type SearchQueryType = z.output<typeof SearchQuerySchema>;
