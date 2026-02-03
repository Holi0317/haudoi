import { tokenize } from "./tokenizer";
import type { FieldConfig, Matcher, ParseResult } from "./types";

/**
 * Known fields and their configurations.
 */
// const KNOWN_FIELDS: Record<string, FieldConfig> = {
//   archive: { name: "archive", type: "boolean", column: "archive" },
//   favorite: { name: "favorite", type: "boolean", column: "favorite" },
//   url: { name: "url", type: "string", column: "url" },
//   title: { name: "title", type: "string", column: "title" },
//   note: { name: "note", type: "string", column: "note" },
// };

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
export function parseDSL(query: string, config: FieldConfig[]): ParseResult {
  const matchers: Matcher[] = [];
  const errors: string[] = [];

  const fieldsMap = new Map(config.map((f) => [f.name.toLowerCase(), f]));

  if (!query || query.trim() === "") {
    return { matchers, errors };
  }

  const tokens = tokenize(query);

  for (const token of tokens) {
    if (token.type === "string") {
      // Loose string
      matchers.push({
        type: "loose",
        value: token.value,
      });
    } else {
      // Field:value pair
      const fieldLower = token.field.toLowerCase();
      const config = fieldsMap.get(fieldLower);

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

  return { matchers, errors };
}
