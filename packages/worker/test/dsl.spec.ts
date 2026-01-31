import { describe, it, expect } from "vitest";
import { parseDSL, matchersToSql, hasErrors } from "../src/composable/dsl";

describe("DSL Parser", () => {
  describe("parseDSL", () => {
    describe("empty and whitespace input", () => {
      it("should return empty matchers for empty string", () => {
        const result = parseDSL("");
        expect(result.matchers).toEqual([]);
        expect(result.errors).toEqual([]);
      });

      it("should return empty matchers for whitespace only", () => {
        const result = parseDSL("   ");
        expect(result.matchers).toEqual([]);
        expect(result.errors).toEqual([]);
      });

      it("should return empty matchers for null-ish input", () => {
        // @ts-expect-error - testing null handling
        const result = parseDSL(null);
        expect(result.matchers).toEqual([]);
        expect(result.errors).toEqual([]);
      });
    });

    describe("loose string matching", () => {
      it("should parse single loose string", () => {
        const result = parseDSL("github");
        expect(result.matchers).toEqual([{ type: "loose", value: "github" }]);
        expect(result.errors).toEqual([]);
      });

      it("should parse multiple loose strings as separate matchers", () => {
        const result = parseDSL("github facebook");
        expect(result.matchers).toEqual([
          { type: "loose", value: "github" },
          { type: "loose", value: "facebook" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse quoted loose string with spaces", () => {
        const result = parseDSL('"hello world"');
        expect(result.matchers).toEqual([
          { type: "loose", value: "hello world" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse single-quoted loose string", () => {
        const result = parseDSL("'hello world'");
        expect(result.matchers).toEqual([
          { type: "loose", value: "hello world" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse backtick-quoted loose string", () => {
        const result = parseDSL("`hello world`");
        expect(result.matchers).toEqual([
          { type: "loose", value: "hello world" },
        ]);
        expect(result.errors).toEqual([]);
      });
    });

    describe("boolean field matching", () => {
      it("should parse archive:true", () => {
        const result = parseDSL("archive:true");
        expect(result.matchers).toEqual([
          { type: "boolean", field: "archive", column: "archive", value: true },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse archive:false", () => {
        const result = parseDSL("archive:false");
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

      it("should parse favorite:true", () => {
        const result = parseDSL("favorite:true");
        expect(result.matchers).toEqual([
          {
            type: "boolean",
            field: "favorite",
            column: "favorite",
            value: true,
          },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse favorite:false", () => {
        const result = parseDSL("favorite:false");
        expect(result.matchers).toEqual([
          {
            type: "boolean",
            field: "favorite",
            column: "favorite",
            value: false,
          },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should be case insensitive for boolean values", () => {
        const result1 = parseDSL("archive:TRUE");
        expect(result1.matchers).toEqual([
          { type: "boolean", field: "archive", column: "archive", value: true },
        ]);

        const result2 = parseDSL("archive:False");
        expect(result2.matchers).toEqual([
          {
            type: "boolean",
            field: "archive",
            column: "archive",
            value: false,
          },
        ]);

        const result3 = parseDSL("archive:TrUe");
        expect(result3.matchers).toEqual([
          { type: "boolean", field: "archive", column: "archive", value: true },
        ]);
      });

      it("should be case insensitive for field names", () => {
        const result1 = parseDSL("ARCHIVE:true");
        expect(result1.matchers).toEqual([
          { type: "boolean", field: "archive", column: "archive", value: true },
        ]);

        const result2 = parseDSL("Archive:true");
        expect(result2.matchers).toEqual([
          { type: "boolean", field: "archive", column: "archive", value: true },
        ]);

        const result3 = parseDSL("FAVORITE:false");
        expect(result3.matchers).toEqual([
          {
            type: "boolean",
            field: "favorite",
            column: "favorite",
            value: false,
          },
        ]);
      });

      it("should error on invalid boolean value", () => {
        const result = parseDSL("archive:yes");
        expect(result.matchers).toEqual([]);
        expect(result.errors).toEqual([
          "Invalid boolean value for archive: yes. Expected 'true' or 'false'.",
        ]);
      });
    });

    describe("string field matching", () => {
      it("should parse title:value", () => {
        const result = parseDSL("title:github");
        expect(result.matchers).toEqual([
          { type: "string", field: "title", column: "title", value: "github" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse url:value", () => {
        const result = parseDSL("url:example.com");
        expect(result.matchers).toEqual([
          { type: "string", field: "url", column: "url", value: "example.com" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse note:value", () => {
        const result = parseDSL("note:important");
        expect(result.matchers).toEqual([
          { type: "string", field: "note", column: "note", value: "important" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse quoted string value with spaces", () => {
        const result = parseDSL('title:"Hello World"');
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
        const result = parseDSL("title:'Hello World'");
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
        const result = parseDSL("title:`Hello World`");
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

      it("should be case insensitive for string field names", () => {
        const result1 = parseDSL("TITLE:test");
        expect(result1.matchers).toEqual([
          { type: "string", field: "title", column: "title", value: "test" },
        ]);

        const result2 = parseDSL("URL:test");
        expect(result2.matchers).toEqual([
          { type: "string", field: "url", column: "url", value: "test" },
        ]);

        const result3 = parseDSL("NOTE:test");
        expect(result3.matchers).toEqual([
          { type: "string", field: "note", column: "note", value: "test" },
        ]);
      });
    });

    describe("unknown field handling", () => {
      it("should error on unknown field", () => {
        const result = parseDSL("unknown:value");
        expect(result.matchers).toEqual([]);
        expect(result.errors).toEqual(["Unknown field: unknown"]);
      });

      it("should continue parsing after unknown field", () => {
        const result = parseDSL("unknown:value title:test");
        expect(result.matchers).toEqual([
          { type: "string", field: "title", column: "title", value: "test" },
        ]);
        expect(result.errors).toEqual(["Unknown field: unknown"]);
      });
    });

    describe("complex queries", () => {
      it("should parse multiple field:value pairs", () => {
        const result = parseDSL("archive:true favorite:false");
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
        const result = parseDSL("archive:true github");
        expect(result.matchers).toEqual([
          { type: "boolean", field: "archive", column: "archive", value: true },
          { type: "loose", value: "github" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse loose string before field:value", () => {
        const result = parseDSL("github archive:true");
        expect(result.matchers).toEqual([
          { type: "loose", value: "github" },
          { type: "boolean", field: "archive", column: "archive", value: true },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should parse complex query with all types", () => {
        const result = parseDSL('archive:false title:"Hello World" github');
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
        const result = parseDSL("archive:true    github    favorite:false");
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
        const result = parseDSL("a b c d e");
        expect(result.matchers.length).toBe(5);
        expect(result.errors).toEqual([]);
      });

      it("should error when exceeding 5 matchers", () => {
        const result = parseDSL("a b c d e f");
        expect(result.matchers.length).toBe(6);
        expect(result.errors).toEqual([
          "Query too complex: 6 matchers exceeds limit of 5.",
        ]);
      });

      it("should error on complex query with many matchers", () => {
        const result = parseDSL(
          "archive:true favorite:false title:a url:b note:c github",
        );
        expect(result.matchers.length).toBe(6);
        expect(result.errors).toHaveLength(1);
        expect(result.errors[0]).toContain("exceeds limit of 5");
      });
    });

    describe("edge cases", () => {
      it("should handle colons in quoted values", () => {
        const result = parseDSL('title:"foo:bar"');
        expect(result.matchers).toEqual([
          { type: "string", field: "title", column: "title", value: "foo:bar" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should handle URL with colons", () => {
        const result = parseDSL("url:http://example.com");
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
        const result = parseDSL('title:""');
        expect(result.matchers).toEqual([
          { type: "string", field: "title", column: "title", value: "" },
        ]);
        expect(result.errors).toEqual([]);
      });

      it("should handle unclosed quote at end", () => {
        const result = parseDSL('title:"hello');
        expect(result.matchers).toEqual([
          { type: "string", field: "title", column: "title", value: "hello" },
        ]);
        expect(result.errors).toEqual([]);
      });
    });
  });

  describe("matchersToSql", () => {
    it("should return null for empty matchers", () => {
      const result = matchersToSql([]);
      expect(result).toBeNull();
    });

    it("should generate SQL for boolean matcher (true)", () => {
      const result = matchersToSql([
        { type: "boolean", field: "archive", column: "archive", value: true },
      ]);
      expect(result).not.toBeNull();
      expect(result!.text).toContain("archive");
      expect(result!.text).toContain("= ?");
      expect(result!.values).toContain(1);
    });

    it("should generate SQL for boolean matcher (false)", () => {
      const result = matchersToSql([
        {
          type: "boolean",
          field: "favorite",
          column: "favorite",
          value: false,
        },
      ]);
      expect(result).not.toBeNull();
      expect(result!.text).toContain("favorite");
      expect(result!.values).toContain(0);
    });

    it("should generate SQL for string matcher", () => {
      const result = matchersToSql([
        { type: "string", field: "title", column: "title", value: "github" },
      ]);
      expect(result).not.toBeNull();
      expect(result!.text).toContain("instr(lower(");
      expect(result!.text).toContain("title");
      expect(result!.values).toContain("github");
    });

    it("should generate SQL for loose matcher", () => {
      const result = matchersToSql([{ type: "loose", value: "github" }]);
      expect(result).not.toBeNull();
      expect(result!.text).toContain("title");
      expect(result!.text).toContain("url");
      expect(result!.text).toContain("note");
      expect(result!.text).toContain("OR");
      expect(result!.values).toContain("github");
    });

    it("should combine multiple matchers with AND", () => {
      const result = matchersToSql([
        { type: "boolean", field: "archive", column: "archive", value: true },
        { type: "string", field: "title", column: "title", value: "test" },
      ]);
      expect(result).not.toBeNull();
      expect(result!.text).toContain("AND");
    });

    it("should combine three matchers with AND", () => {
      const result = matchersToSql([
        { type: "boolean", field: "archive", column: "archive", value: true },
        {
          type: "boolean",
          field: "favorite",
          column: "favorite",
          value: false,
        },
        { type: "loose", value: "github" },
      ]);
      expect(result).not.toBeNull();
      // Should have two ANDs for three conditions
      const andCount = (result!.text.match(/AND/g) || []).length;
      expect(andCount).toBe(2);
    });
  });

  describe("hasErrors", () => {
    it("should return false when no errors", () => {
      const result = { matchers: [], errors: [] };
      expect(hasErrors(result)).toBe(false);
    });

    it("should return true when errors exist", () => {
      const result = { matchers: [], errors: ["Some error"] };
      expect(hasErrors(result)).toBe(true);
    });
  });
});
