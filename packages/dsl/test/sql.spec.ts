import { describe, it, expect } from "vitest";
import { matchersToSql } from "../src/sql";
import { sql } from "@truto/sqlite-builder";

describe("matchersToSql", () => {
  it("should return 1=1 for empty matchers", () => {
    const result = matchersToSql([], []);
    expect(result.text).toBe("1=1");
  });

  it("should generate SQL for boolean matcher (true)", () => {
    const result = matchersToSql(
      [{ type: "boolean", field: "archive", column: "archive", value: true }],
      [],
    );

    expect(result).toEqual(sql`"archive" = ${1}`);
  });

  it("should generate SQL for boolean matcher (false)", () => {
    const result = matchersToSql(
      [
        {
          type: "boolean",
          field: "favorite",
          column: "favorite",
          value: false,
        },
      ],
      [],
    );

    expect(result).toEqual(sql`"favorite" = ${0}`);
  });

  it("should generate SQL for string matcher", () => {
    const result = matchersToSql(
      [{ type: "string", field: "title", column: "title", value: "github" }],
      [],
    );

    expect(result).toEqual(sql`instr(lower("title"), lower(${"github"})) != 0`);
  });

  it("should generate SQL for loose matcher", () => {
    const result = matchersToSql(
      [{ type: "loose", value: "github" }],
      ["title", "url"],
    );

    expect(result).toEqual(
      sql`(instr(lower("title"), lower(${"github"})) != 0 OR instr(lower("url"), lower(${"github"})) != 0)`,
    );
  });

  it("should raise error for loose matcher with no columns", () => {
    expect(() =>
      matchersToSql([{ type: "loose", value: "test" }], []),
    ).toThrowError("No searchable columns configured for loose matcher");
  });

  it("should combine multiple matchers with AND", () => {
    const result = matchersToSql(
      [
        { type: "boolean", field: "archive", column: "archive", value: true },
        { type: "string", field: "title", column: "title", value: "test" },
      ],
      [],
    );

    expect(result).toEqual(
      sql`"archive" = ${1} AND instr(lower("title"), lower(${"test"})) != 0`,
    );
  });

  it("should combine three matchers with AND", () => {
    const result = matchersToSql(
      [
        { type: "boolean", field: "archive", column: "archive", value: true },
        {
          type: "boolean",
          field: "favorite",
          column: "favorite",
          value: false,
        },
        { type: "loose", value: "github" },
      ],
      ["title", "url"],
    );

    expect(result).toEqual(
      sql`"archive" = ${1} AND "favorite" = ${0} AND (instr(lower("title"), lower(${"github"})) != 0 OR instr(lower("url"), lower(${"github"})) != 0)`,
    );
  });
});
