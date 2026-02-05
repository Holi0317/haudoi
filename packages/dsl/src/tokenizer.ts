import { MAX_COMPLEXITY } from "./constants";

/**
 * Token types for the lexer.
 */
export type Token =
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
 * @throws Error if complexity limit exceeded
 */
export function tokenize(query: string): Token[] {
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

    // Check complexity limit
    if (tokens.length > MAX_COMPLEXITY) {
      throw new Error(
        "Query exceeds maximum complexity. Try reduce search terms.",
      );
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
