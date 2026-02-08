import * as z from "zod";

/**
 * Simple id coerce into a number schema.
 */
export const IDStringSchema = z.object({
  id: z.coerce.number(),
});

/**
 * Common schema for SQL query selecting id column.
 */
export const IDSchema = z.strictObject({
  id: z.number(),
});

/**
 * Common schema for SQL query selecting count column/expression.
 */
export const CountSchema = z.strictObject({
  count: z.number(),
});
