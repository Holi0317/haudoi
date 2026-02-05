/**
 * DSL (Domain Specific Language) parser for search queries.
 *
 * The DSL is similar to GitHub's issue and PR search syntax.
 *
 * This package provides tokenizer (not exposed), parser, and SQL conversion functions.
 * Refer to CONTRIBUTION.md for expected SQL schema design and conventions.
 *
 * Rules:
 * - `field:value` for specifying field match. Fields must be known/configured and matched case sensitively.
 * - Boolean fields accept `true` or `false` (case insensitive)
 * - String fields are searched through case insensitive substring match
 * - Value can be string without space, or quoted with `"`, `'` or backtick
 * - Spaces outside quotes treated as AND combination
 * - Complexity limit of 5 matchers. Exceeding this throws an error.
 *
 * @module
 */

export { parseDSL } from "./parser";
export { matchersToSql } from "./sql";
export type * from "./types";
