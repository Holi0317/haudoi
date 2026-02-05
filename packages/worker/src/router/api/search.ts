import { parseDSL } from "@haudoi/dsl";
import type { ParseResult, FieldConfig } from "@haudoi/dsl";
import { getStorageStub } from "../../composable/do";
import { zv } from "../../composable/validator";
import { SearchQuerySchema } from "../../schemas";
import { factory } from "../factory";
import { InvalidSearchQueryError } from "../../error/search";
import { encodeCursor } from "../../composable/cursor";

/**
 * Field configuration for DSL search
 */
const SEARCH_FIELDS: FieldConfig[] = [
  { name: "archive", type: "boolean", column: "archive" },
  { name: "favorite", type: "boolean", column: "favorite" },
  { name: "url", type: "string", column: "url" },
  { name: "title", type: "string", column: "title" },
  { name: "note", type: "string", column: "note" },
];

export default factory
  .createApp()
  .get("/", zv("query", SearchQuerySchema), async (c) => {
    const stub = await getStorageStub(c);

    const q = c.req.valid("query");

    // Parse DSL query string
    let parseResult: ParseResult;
    try {
      parseResult = parseDSL(q.query, SEARCH_FIELDS);
    } catch (error) {
      throw new InvalidSearchQueryError(
        error instanceof Error ? error.message : "Invalid search query",
        undefined,
        error,
      );
    }

    // Check for parsing errors (e.g., unknown field)
    if (parseResult.errors.length > 0) {
      throw new InvalidSearchQueryError(
        `Invalid search query: ${parseResult.errors.join("; ")}`,
        parseResult.errors,
      );
    }

    const search = await stub.search(
      { limit: q.limit, order: q.order, cursor: q.cursor },
      parseResult.matchers,
    );

    const lastItem = search.items.at(-1);
    const cursor =
      lastItem == null || !search.hasMore ? null : encodeCursor(lastItem);

    return c.json({
      ...search,
      cursor,
    });
  });
