import type { SqlQuery } from "@truto/sqlite-builder";

/**
 * Configuration for a known field.
 */
export type FieldConfig =
  | {
      /**
       * Field name in DSL.
       */
      name: string;
      /**
       * Type of the field in DSL.
       */
      type: "boolean";
      /**
       * Generate a SQL fragment for this field given the parsed boolean value.
       */
      toSql: (value: boolean) => SqlQuery;
    }
  | {
      /**
       * Field name in DSL.
       */
      name: string;
      /**
       * Type of the field in DSL.
       */
      type: "string";
      /**
       * Generate a SQL fragment for this field given the parsed string value.
       */
      toSql: (value: string) => SqlQuery;
    };

/**
 * Represents a parsed matcher from DSL.
 */
export type Matcher =
  | {
      type: "field";
      field: string;
      sql: SqlQuery;
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
