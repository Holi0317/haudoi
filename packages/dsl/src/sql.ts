import { sql, type SqlQuery } from "@truto/sqlite-builder";
import type { Matcher } from "./types";

/**
 * Boolean matcher factory for a given column. Used in FieldConfig.
 *
 * @param column SQL column name (with optional table prefix) to compare against
 */
export function boolMatcher(column: string) {
  return (value: boolean): SqlQuery => {
    const col = sql.ident(column);
    return sql`${col} = ${Number(value)}`;
  };
}

/**
 * String matcher factory for a given column. Used in FieldConfig.
 *
 * The string matching is done in case-insensitive way.
 *
 * @param column SQL column name (with optional table prefix) to compare against
 */
export function stringMatcher(column: string) {
  return (value: string): SqlQuery => {
    const col = sql.ident(column);
    return sql`instr(lower(${col}), lower(${value})) != 0`;
  };
}

/**
 * Convert matchers to SQL WHERE clause fragment.
 *
 * Returns a SQL fragment that can be used in a WHERE clause.
 * Multiple matchers are combined with AND.
 *
 * @param matchers Array of matchers from parseDSL
 * @param looseColumns Columns (with optional relation prefix) to search for loose string matchers
 * @returns SQL fragment for WHERE clause
 */
export function matchersToSql(
  matchers: Matcher[],
  looseColumns: string[],
): SqlQuery {
  if (matchers.length === 0) {
    // No matchers, return always true placeholder condition
    return sql`1=1`;
  }

  // Build conditions for each matcher
  const conditions: SqlQuery[] = [];

  for (const matcher of matchers) {
    if (matcher.type === "field") {
      conditions.push(matcher.sql);
    } else if (matcher.type === "loose") {
      // Loose string matches base on configured columns
      // Build OR conditions for each searchable column
      const looseConditions = looseColumns.map(
        (col) =>
          sql`instr(lower(${sql.ident(col)}), lower(${matcher.value})) != 0`,
      );

      if (looseConditions.length === 0) {
        throw new Error("No searchable columns configured for loose matcher");
      }

      conditions.push(sql`(${sql.join(looseConditions, " OR ")})`);
    }
  }

  // Combine all conditions with AND
  return sql.join(conditions, " AND ");
}
