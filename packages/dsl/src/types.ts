/**
 * Field types for DSL matchers.
 */
export type FieldType = "boolean" | "string";

/**
 * Configuration for a known field.
 */
export interface FieldConfig {
  /**
   * Field name in DSL.
   */
  name: string;
  /**
   * Type of the field.
   */
  type: FieldType;
  /**
   * Corresponding column name in SQL. Can be different from field name in `name`.
   */
  column: string;
}

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
