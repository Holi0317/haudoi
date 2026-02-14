import { parseDSL, boolMatcher, stringMatcher } from "@haudoi/dsl";
import type { ParseResult, FieldConfig } from "@haudoi/dsl";
import { getStorageStub } from "../../composable/do";
import { zv } from "../../composable/validator";
import { SearchQuerySchema } from "../../schemas";
import { factory } from "../factory";
import { InvalidSearchQueryError } from "../../error/search";
import { encodeCursor } from "../../composable/cursor";
import { sql } from "../../composable/sql";

/**
 * Field configuration for DSL search
 */
const SEARCH_FIELDS: FieldConfig[] = [
  {
    name: "archive",
    type: "boolean",
    toSql: boolMatcher("l.archive"),
  },
  {
    name: "favorite",
    type: "boolean",
    toSql: boolMatcher("l.favorite"),
  },
  {
    name: "url",
    type: "string",
    toSql: stringMatcher("l.url"),
  },
  {
    name: "title",
    type: "string",
    toSql: stringMatcher("l.title"),
  },
  {
    name: "note",
    type: "string",
    toSql: stringMatcher("l.note"),
  },
  {
    name: "tag",
    type: "string",
    toSql: (value) => sql`EXISTS (
SELECT 1 FROM link_tag
  JOIN tag ON tag.id = link_tag.tag_id
WHERE link_tag.link_id = l.id
  AND lower(tag.name) = lower(${value})
    )`,
  },
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
