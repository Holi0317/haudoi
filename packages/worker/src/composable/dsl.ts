/**
 * DSL (Domain Specific Language) parser for search queries.
 *
 * The DSL is similar to GitHub's issue and PR search syntax.
 *
 * Rules:
 * - `field:value` for specifying field match
 * - Boolean fields accept `true` or `false` (case insensitive)
 * - String fields are searched through case insensitive substring match
 * - Available fields: `archive`, `favorite`, `url`, `title`, `note` (case insensitive)
 * - Value can be string without space, or quoted with `"`, `'` or backtick
 * - Spaces outside quotes treated as AND combination
 * - Loose string without key matches `url`, `title` and `note`
 * - Complexity limit of 5 matchers
 *
 * @module
 */

import { sql } from "./sql";
import type { SqlQuery } from "@truto/sqlite-builder";

/**
 * Maximum number of matchers allowed in a query.
 */
const MAX_COMPLEXITY = 5;

/**
 * Field types for DSL matchers.
 */
type FieldType = "boolean" | "string";

/**
 * Configuration for a known field.
 */
interface FieldConfig {
  name: string;
  type: FieldType;
  column: string;
}

/**
 * Known fields and their configurations.
 */
const KNOWN_FIELDS: Record<string, FieldConfig> = {
  archive: { name: "archive", type: "boolean", column: "archive" },
  favorite: { name: "favorite", type: "boolean", column: "favorite" },
  url: { name: "url", type: "string", column: "url" },
  title: { name: "title", type: "string", column: "title" },
  note: { name: "note", type: "string", column: "note" },
};

/**
 * Represents a parsed matcher from DSL.
 */
export type Matcher =
  | {
      type: "boolean";
      field: string;
      column: string;
      value: boolean;
    }
  | {
      type: "string";
      field: string;
      column: string;
      value: string;
    }
  | {
      type: "loose";
      value: string;
    };

/**
 * Result of parsing a DSL query.
 */
export interface ParseResult {
  matchers: Matcher[];
  errors: string[];
}

/**
 * Token types for the lexer.
 */
type Token =
  | { type: "field_value"; field: string; value: string }
  | { type: "string"; value: string };

/**
 * Tokenize a DSL query string.
 *
 * This handles:
 * - Quoted values with ", ', or `
 * - Field:value pairs
 * - Loose strings
 *
 * @param query The query string to tokenize
 * @returns Array of tokens
 */
function tokenize(query: string): Token[] {
  const tokens: Token[] = [];
  let i = 0;

  while (i < query.length) {
    // Skip whitespace
    if (/\s/.test(query[i])) {
      i++;
      continue;
    }

    // Try to parse a field:value pair or loose string
    const result = parseToken(query, i);
    if (result) {
      tokens.push(result.token);
      i = result.end;
    } else {
      // This shouldn't happen with a well-formed input, but skip if it does
      i++;
    }
  }

  return tokens;
}

/**
 * Parse a single token from the query string starting at the given position.
 */
function parseToken(
  query: string,
  start: number,
): { token: Token; end: number } | null {
  // Check if this is a field:value pair
  const colonIndex = findColon(query, start);

  if (colonIndex !== -1) {
    // Found a colon, this might be field:value
    const fieldPart = query.slice(start, colonIndex);

    // Field must be non-empty and not contain quotes or spaces
    if (fieldPart.length > 0 && !/[\s"'`]/.test(fieldPart)) {
      const valueResult = parseValue(query, colonIndex + 1);
      if (valueResult) {
        return {
          token: {
            type: "field_value",
            field: fieldPart,
            value: valueResult.value,
          },
          end: valueResult.end,
        };
      }
    }
  }

  // Not a field:value pair, parse as loose string
  const valueResult = parseValue(query, start);
  if (valueResult) {
    return {
      token: { type: "string", value: valueResult.value },
      end: valueResult.end,
    };
  }

  return null;
}

/**
 * Find the next colon that's not inside quotes.
 */
function findColon(query: string, start: number): number {
  let i = start;

  while (i < query.length) {
    const char = query[i];

    if (char === ":") {
      return i;
    }

    if (char === '"' || char === "'" || char === "`") {
      // Skip to end of quoted string
      i++;
      while (i < query.length && query[i] !== char) {
        i++;
      }
      if (i < query.length) {
        i++; // Skip closing quote
      }
      continue;
    }

    if (/\s/.test(char)) {
      // Hit whitespace before colon, not a field:value
      return -1;
    }

    i++;
  }

  return -1;
}

/**
 * Parse a value starting at the given position.
 * Handles quoted and unquoted values.
 */
function parseValue(
  query: string,
  start: number,
): { value: string; end: number } | null {
  if (start >= query.length) {
    return null;
  }

  const firstChar = query[start];

  // Quoted value
  if (firstChar === '"' || firstChar === "'" || firstChar === "`") {
    const quoteChar = firstChar;
    let i = start + 1;
    let value = "";

    while (i < query.length && query[i] !== quoteChar) {
      value += query[i];
      i++;
    }

    // Skip closing quote if present
    if (i < query.length) {
      i++;
    }

    return { value, end: i };
  }

  // Unquoted value - read until whitespace
  let i = start;
  let value = "";

  while (i < query.length && !/\s/.test(query[i])) {
    value += query[i];
    i++;
  }

  if (value.length === 0) {
    return null;
  }

  return { value, end: i };
}

/**
 * Parse a boolean value from a string.
 *
 * @param value The string to parse
 * @returns true/false if valid, or null if invalid
 */
function parseBoolean(value: string): boolean | null {
  const lower = value.toLowerCase();
  if (lower === "true") {
    return true;
  }
  if (lower === "false") {
    return false;
  }
  return null;
}

/**
 * Parse a DSL query string into matchers.
 *
 * @param query The query string to parse
 * @returns ParseResult with matchers and any errors
 */
export function parseDSL(query: string): ParseResult {
  const matchers: Matcher[] = [];
  const errors: string[] = [];

  if (!query || query.trim() === "") {
    return { matchers, errors };
  }

  const tokens = tokenize(query);

  for (const token of tokens) {
    if (token.type === "string") {
      // Loose string - matches url, title, note
      matchers.push({
        type: "loose",
        value: token.value,
      });
    } else {
      // Field:value pair
      const fieldLower = token.field.toLowerCase();
      const config = KNOWN_FIELDS[fieldLower];

      if (!config) {
        errors.push(`Unknown field: ${token.field}`);
        continue;
      }

      if (config.type === "boolean") {
        const boolValue = parseBoolean(token.value);
        if (boolValue === null) {
          errors.push(
            `Invalid boolean value for ${token.field}: ${token.value}. Expected 'true' or 'false'.`,
          );
          continue;
        }
        matchers.push({
          type: "boolean",
          field: config.name,
          column: config.column,
          value: boolValue,
        });
      } else {
        // String field
        matchers.push({
          type: "string",
          field: config.name,
          column: config.column,
          value: token.value,
        });
      }
    }
  }

  // Check complexity limit
  if (matchers.length > MAX_COMPLEXITY) {
    errors.push(
      `Query too complex: ${matchers.length} matchers exceeds limit of ${MAX_COMPLEXITY}.`,
    );
  }

  return { matchers, errors };
}

/**
 * Convert matchers to SQL WHERE clause fragment.
 *
 * Returns a SQL fragment that can be used in a WHERE clause.
 * Multiple matchers are combined with AND.
 *
 * @param matchers Array of matchers from parseDSL
 * @returns SQL fragment for WHERE clause, or null if no matchers
 */
export function matchersToSql(matchers: Matcher[]): SqlQuery | null {
  if (matchers.length === 0) {
    return null;
  }

  // Build conditions for each matcher
  const conditions: SqlQuery[] = [];

  for (const matcher of matchers) {
    if (matcher.type === "boolean") {
      const column = sql.ident(matcher.column);
      conditions.push(sql`${column} = ${Number(matcher.value)}`);
    } else if (matcher.type === "string") {
      const column = sql.ident(matcher.column);
      conditions.push(
        sql`instr(lower(${column}), lower(${matcher.value})) != 0`,
      );
    } else if (matcher.type === "loose") {
      // Loose string matches url, title, or note
      // Build OR conditions for each searchable column
      const looseColumns = ["title", "url", "note"];
      const looseConditions = looseColumns.map(
        (col) =>
          sql`instr(lower(${sql.ident(col)}), lower(${matcher.value})) != 0`,
      );

      // Join with OR
      let looseResult = looseConditions[0];
      for (let i = 1; i < looseConditions.length; i++) {
        looseResult = sql`${looseResult} OR ${looseConditions[i]}`;
      }
      conditions.push(sql`(${looseResult})`);
    }
  }

  // Combine all conditions with AND
  if (conditions.length === 1) {
    return conditions[0];
  }

  // Build combined condition
  let result = conditions[0];
  for (let i = 1; i < conditions.length; i++) {
    result = sql`${result} AND ${conditions[i]}`;
  }

  return result;
}

/**
 * Check if a parse result has errors that should prevent search.
 *
 * @param result Parse result from parseDSL
 * @returns true if there are critical errors
 */
export function hasErrors(result: ParseResult): boolean {
  return result.errors.length > 0;
}
