import { describe, it, expect } from "vitest";
import { parseDSL } from "../src/parser";
import type { FieldConfig } from "../src";

describe("parseDSL", () => {
  describe("empty and whitespace input", () => {
    it("should return empty matchers for empty string", () => {
      const result = parseDSL("", []);
      expect(result.matchers).toEqual([]);
      expect(result.errors).toEqual([]);
    });

    it("should return empty matchers for whitespace only", () => {
      const result = parseDSL("   ", []);
      expect(result.matchers).toEqual([]);
      expect(result.errors).toEqual([]);
    });
  });

  describe("loose string matching", () => {
    it("should parse single loose string", () => {
      const result = parseDSL("github", []);
      expect(result.matchers).toEqual([{ type: "loose", value: "github" }]);
      expect(result.errors).toEqual([]);
    });

    it("should parse multiple loose strings as separate matchers", () => {
      const result = parseDSL("github facebook", []);
      expect(result.matchers).toEqual([
        { type: "loose", value: "github" },
        { type: "loose", value: "facebook" },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse quoted loose string with spaces", () => {
      const result = parseDSL('"hello world"', []);
      expect(result.matchers).toEqual([
        { type: "loose", value: "hello world" },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse single-quoted loose string", () => {
      const result = parseDSL("'hello world'", []);
      expect(result.matchers).toEqual([
        { type: "loose", value: "hello world" },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse backtick-quoted loose string", () => {
      const result = parseDSL("`hello world`", []);
      expect(result.matchers).toEqual([
        { type: "loose", value: "hello world" },
      ]);
      expect(result.errors).toEqual([]);
    });
  });

  describe("boolean field matching", () => {
    const config: FieldConfig[] = [
      { name: "archive", type: "boolean", column: "archive" },
    ];

    it("should parse archive:true", () => {
      const result = parseDSL("archive:true", config);
      expect(result.matchers).toEqual([
        { type: "boolean", field: "archive", column: "archive", value: true },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse archive:false", () => {
      const result = parseDSL("archive:false", config);
      expect(result.matchers).toEqual([
        {
          type: "boolean",
          field: "archive",
          column: "archive",
          value: false,
        },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should be case insensitive for boolean values", () => {
      const result = parseDSL(
        "archive:TRUE archive:False archive:TrUe",
        config,
      );
      expect(result.matchers).toEqual([
        { type: "boolean", field: "archive", column: "archive", value: true },
        { type: "boolean", field: "archive", column: "archive", value: false },
        { type: "boolean", field: "archive", column: "archive", value: true },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should error on invalid boolean value", () => {
      const result = parseDSL("archive:yes", config);
      expect(result.matchers).toEqual([]);
      expect(result.errors).toEqual([
        "Invalid boolean value for archive: yes. Expected 'true' or 'false'.",
      ]);
    });
  });

  describe("string field matching", () => {
    const config: FieldConfig[] = [
      { name: "title", type: "string", column: "title" },
    ];

    it("should parse title:value", () => {
      const result = parseDSL("title:github", config);
      expect(result.matchers).toEqual([
        { type: "string", field: "title", column: "title", value: "github" },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse quoted string value with spaces", () => {
      const result = parseDSL('title:"Hello World"', config);
      expect(result.matchers).toEqual([
        {
          type: "string",
          field: "title",
          column: "title",
          value: "Hello World",
        },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse single-quoted string value", () => {
      const result = parseDSL("title:'Hello World'", config);
      expect(result.matchers).toEqual([
        {
          type: "string",
          field: "title",
          column: "title",
          value: "Hello World",
        },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse backtick-quoted string value", () => {
      const result = parseDSL("title:`Hello World`", config);
      expect(result.matchers).toEqual([
        {
          type: "string",
          field: "title",
          column: "title",
          value: "Hello World",
        },
      ]);
      expect(result.errors).toEqual([]);
    });
  });

  describe("unknown field handling", () => {
    it("should error on unknown field", () => {
      const result = parseDSL("unknown:value", []);
      expect(result.matchers).toEqual([]);
      expect(result.errors).toEqual(["Unknown field: unknown"]);
    });

    it("should match fields case sensitively for known fields", () => {
      const result = parseDSL("Title:test", [
        { name: "title", type: "string", column: "title" },
      ]);

      expect(result.matchers).toEqual([]);
      expect(result.errors).toEqual(["Unknown field: Title"]);
    });

    it("should continue parsing after unknown field", () => {
      const result = parseDSL("unknown:value title:test", [
        { name: "title", type: "string", column: "title" },
      ]);
      expect(result.matchers).toEqual([
        { type: "string", field: "title", column: "title", value: "test" },
      ]);
      expect(result.errors).toEqual(["Unknown field: unknown"]);
    });
  });

  describe("complex queries", () => {
    const config: FieldConfig[] = [
      { name: "archive", type: "boolean", column: "archive" },
      { name: "favorite", type: "boolean", column: "favorite" },
      { name: "title", type: "string", column: "title" },
    ];

    it("should parse multiple field:value pairs", () => {
      const result = parseDSL("archive:true favorite:false", config);
      expect(result.matchers).toEqual([
        { type: "boolean", field: "archive", column: "archive", value: true },
        {
          type: "boolean",
          field: "favorite",
          column: "favorite",
          value: false,
        },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse mixed field:value and loose strings", () => {
      const result = parseDSL("archive:true github", config);
      expect(result.matchers).toEqual([
        { type: "boolean", field: "archive", column: "archive", value: true },
        { type: "loose", value: "github" },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse loose string before field:value", () => {
      const result = parseDSL("github archive:true", config);
      expect(result.matchers).toEqual([
        { type: "loose", value: "github" },
        { type: "boolean", field: "archive", column: "archive", value: true },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should parse complex query with all types", () => {
      const result = parseDSL(
        'archive:false title:"Hello World" github',
        config,
      );
      expect(result.matchers).toEqual([
        {
          type: "boolean",
          field: "archive",
          column: "archive",
          value: false,
        },
        {
          type: "string",
          field: "title",
          column: "title",
          value: "Hello World",
        },
        { type: "loose", value: "github" },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should handle extra whitespace between terms", () => {
      const result = parseDSL(
        "archive:true    github    favorite:false",
        config,
      );
      expect(result.matchers).toEqual([
        { type: "boolean", field: "archive", column: "archive", value: true },
        { type: "loose", value: "github" },
        {
          type: "boolean",
          field: "favorite",
          column: "favorite",
          value: false,
        },
      ]);
      expect(result.errors).toEqual([]);
    });
  });

  describe("complexity limit", () => {
    it("should allow up to 5 matchers", () => {
      const result = parseDSL("a b c d e", []);
      expect(result.matchers.length).toBe(5);
      expect(result.errors).toEqual([]);
    });

    it("should error when exceeding 5 matchers", () => {
      expect(() => {
        parseDSL("a b c d e f", []);
      }).toThrowError(
        "Query exceeds maximum complexity. Try reduce search terms.",
      );
    });
  });

  describe("edge cases", () => {
    const config: FieldConfig[] = [
      { name: "title", type: "string", column: "title" },
      { name: "url", type: "string", column: "url" },
    ];

    it("should handle colons in quoted values", () => {
      const result = parseDSL('title:"foo:bar"', config);
      expect(result.matchers).toEqual([
        { type: "string", field: "title", column: "title", value: "foo:bar" },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should handle URL with colons", () => {
      const result = parseDSL("url:http://example.com", config);
      expect(result.matchers).toEqual([
        {
          type: "string",
          field: "url",
          column: "url",
          value: "http://example.com",
        },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should handle empty quoted value", () => {
      const result = parseDSL('title:""', config);
      expect(result.matchers).toEqual([
        { type: "string", field: "title", column: "title", value: "" },
      ]);
      expect(result.errors).toEqual([]);
    });

    it("should handle unclosed quote at end", () => {
      const result = parseDSL('title:"hello', config);
      expect(result.matchers).toEqual([
        { type: "string", field: "title", column: "title", value: "hello" },
      ]);
      expect(result.errors).toEqual([]);
    });
  });
});
