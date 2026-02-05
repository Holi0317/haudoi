import { describe, it, expect } from "vitest";
import { tokenize } from "../src/tokenizer";

describe("tokenize", () => {
  describe("simple strings", () => {
    it("should tokenize a single word", () => {
      const result = tokenize("hello");
      expect(result).toEqual([{ type: "string", value: "hello" }]);
    });

    it("should tokenize multiple words as separate tokens", () => {
      const result = tokenize("hello world");
      expect(result).toEqual([
        { type: "string", value: "hello" },
        { type: "string", value: "world" },
      ]);
    });

    it("should handle multiple spaces between words", () => {
      const result = tokenize("hello   world");
      expect(result).toEqual([
        { type: "string", value: "hello" },
        { type: "string", value: "world" },
      ]);
    });

    it("should ignore leading whitespace", () => {
      const result = tokenize("   hello");
      expect(result).toEqual([{ type: "string", value: "hello" }]);
    });

    it("should ignore trailing whitespace", () => {
      const result = tokenize("hello   ");
      expect(result).toEqual([{ type: "string", value: "hello" }]);
    });

    it("should handle tabs and newlines as whitespace", () => {
      const result = tokenize("hello\t\nworld");
      expect(result).toEqual([
        { type: "string", value: "hello" },
        { type: "string", value: "world" },
      ]);
    });
  });

  describe("quoted strings", () => {
    it("should handle double-quoted strings", () => {
      const result = tokenize('"hello world"');
      expect(result).toEqual([{ type: "string", value: "hello world" }]);
    });

    it("should handle single-quoted strings", () => {
      const result = tokenize("'hello world'");
      expect(result).toEqual([{ type: "string", value: "hello world" }]);
    });

    it("should handle backtick-quoted strings", () => {
      const result = tokenize("`hello world`");
      expect(result).toEqual([{ type: "string", value: "hello world" }]);
    });

    it("should handle quoted strings with special characters", () => {
      const result = tokenize('"hello@world.com"');
      expect(result).toEqual([{ type: "string", value: "hello@world.com" }]);
    });

    it("should handle quoted strings with numbers", () => {
      const result = tokenize('"test123"');
      expect(result).toEqual([{ type: "string", value: "test123" }]);
    });

    it("should handle empty quoted strings", () => {
      const result = tokenize('""');
      expect(result).toEqual([{ type: "string", value: "" }]);
    });

    it("should handle unclosed quoted strings", () => {
      const result = tokenize('"hello');
      expect(result).toEqual([{ type: "string", value: "hello" }]);
    });

    it("should handle quotes inside different quote types", () => {
      const result = tokenize(`"hello'world"`);
      expect(result).toEqual([{ type: "string", value: "hello'world" }]);
    });

    it("should handle multiple quoted strings", () => {
      const result = tokenize('"hello" "world"');
      expect(result).toEqual([
        { type: "string", value: "hello" },
        { type: "string", value: "world" },
      ]);
    });
  });

  describe("field:value pairs", () => {
    it("should tokenize simple field:value pairs", () => {
      const result = tokenize("field:value");
      expect(result).toEqual([
        { type: "field_value", field: "field", value: "value" },
      ]);
    });

    it("should handle field:value with quoted value", () => {
      const result = tokenize('field:"hello world"');
      expect(result).toEqual([
        { type: "field_value", field: "field", value: "hello world" },
      ]);
    });

    it("should handle field:value with single-quoted value", () => {
      const result = tokenize("field:'hello world'");
      expect(result).toEqual([
        { type: "field_value", field: "field", value: "hello world" },
      ]);
    });

    it("should handle field:value with backtick-quoted value", () => {
      const result = tokenize("field:`hello world`");
      expect(result).toEqual([
        { type: "field_value", field: "field", value: "hello world" },
      ]);
    });

    it("should handle multiple field:value pairs", () => {
      const result = tokenize("name:john age:30");
      expect(result).toEqual([
        { type: "field_value", field: "name", value: "john" },
        { type: "field_value", field: "age", value: "30" },
      ]);
    });

    it("should handle field:value with special characters in field", () => {
      const result = tokenize("user_id:123");
      expect(result).toEqual([
        { type: "field_value", field: "user_id", value: "123" },
      ]);
    });

    it("should handle field:value with dashes in field", () => {
      const result = tokenize("user-id:123");
      expect(result).toEqual([
        { type: "field_value", field: "user-id", value: "123" },
      ]);
    });

    it("should handle field:value with dots in field", () => {
      const result = tokenize("user.id:123");
      expect(result).toEqual([
        { type: "field_value", field: "user.id", value: "123" },
      ]);
    });

    it("should handle empty field value", () => {
      const result = tokenize('field:""');
      expect(result).toEqual([
        { type: "field_value", field: "field", value: "" },
      ]);
    });

    it("should handle field:value with special characters in value", () => {
      const result = tokenize('email:"test@example.com"');
      expect(result).toEqual([
        { type: "field_value", field: "email", value: "test@example.com" },
      ]);
    });

    it("should treat word:space as loose string, not field:value", () => {
      const result = tokenize("word: value");
      expect(result).toEqual([
        { type: "string", value: "word:" },
        { type: "string", value: "value" },
      ]);
    });

    it("should not treat quoted:value as field:value", () => {
      const result = tokenize('"field:value"');
      expect(result).toEqual([{ type: "string", value: "field:value" }]);
    });
  });

  describe("mixed content", () => {
    it("should handle mix of strings and field:value pairs", () => {
      const result = tokenize('search text field:"value"');
      expect(result).toEqual([
        { type: "string", value: "search" },
        { type: "string", value: "text" },
        { type: "field_value", field: "field", value: "value" },
      ]);
    });

    it("should handle field:value followed by strings", () => {
      const result = tokenize("name:john doe");
      expect(result).toEqual([
        { type: "field_value", field: "name", value: "john" },
        { type: "string", value: "doe" },
      ]);
    });

    it("should handle strings between field:value pairs", () => {
      const result = tokenize("from:john test to:jane");
      expect(result).toEqual([
        { type: "field_value", field: "from", value: "john" },
        { type: "string", value: "test" },
        { type: "field_value", field: "to", value: "jane" },
      ]);
    });

    it("should handle complex real-world query", () => {
      const result = tokenize('subject:"urgent meeting" from:boss date:2024');
      expect(result).toEqual([
        { type: "field_value", field: "subject", value: "urgent meeting" },
        { type: "field_value", field: "from", value: "boss" },
        { type: "field_value", field: "date", value: "2024" },
      ]);
    });
  });

  describe("edge cases", () => {
    it("should handle empty string", () => {
      const result = tokenize("");
      expect(result).toEqual([]);
    });

    it("should handle whitespace only", () => {
      const result = tokenize("   ");
      expect(result).toEqual([]);
    });

    it("should handle single character", () => {
      const result = tokenize("a");
      expect(result).toEqual([{ type: "string", value: "a" }]);
    });

    it("should handle single character field:value", () => {
      const result = tokenize("a:b");
      expect(result).toEqual([{ type: "field_value", field: "a", value: "b" }]);
    });

    it("should handle very long string", () => {
      const longString = "a".repeat(1000);
      const result = tokenize(longString);
      expect(result).toEqual([{ type: "string", value: longString }]);
    });

    it("should handle colons in unquoted values", () => {
      const result = tokenize("url:http://example.com");
      expect(result).toEqual([
        { type: "field_value", field: "url", value: "http://example.com" },
      ]);
    });

    it("should handle multiple colons in quoted values", () => {
      const result = tokenize('url:"http://example.com:8080/path"');
      expect(result).toEqual([
        {
          type: "field_value",
          field: "url",
          value: "http://example.com:8080/path",
        },
      ]);
    });

    it("should handle numeric values", () => {
      const result = tokenize("123 456");
      expect(result).toEqual([
        { type: "string", value: "123" },
        { type: "string", value: "456" },
      ]);
    });

    it("should handle special characters in unquoted values", () => {
      const result = tokenize("test@123");
      expect(result).toEqual([{ type: "string", value: "test@123" }]);
    });
  });

  describe("complexity limit", () => {
    it("should throw error when exceeding MAX_COMPLEXITY", () => {
      // MAX_COMPLEXITY is 5, so 6 tokens should throw
      const query = "one two three four five six";
      expect(() => tokenize(query)).toThrow(
        "Query exceeds maximum complexity. Try reduce search terms.",
      );
    });

    it("should not throw with exactly MAX_COMPLEXITY tokens", () => {
      const query = "one two three four five";
      expect(() => tokenize(query)).not.toThrow();
      const result = tokenize(query);
      expect(result).toHaveLength(5);
    });

    it("should count field:value as one token", () => {
      // 5 field:value pairs = 5 tokens (at max)
      const query = "a:1 b:2 c:3 d:4 e:5";
      expect(() => tokenize(query)).not.toThrow();
      const result = tokenize(query);
      expect(result).toHaveLength(5);
    });

    it("should count mixed tokens toward complexity", () => {
      // 2 strings + 3 field:value = 5 tokens (at max)
      const query = "word1 word2 a:1 b:2 c:3";
      expect(() => tokenize(query)).not.toThrow();
      const result = tokenize(query);
      expect(result).toHaveLength(5);
    });
  });

  describe("field validation", () => {
    it("should not treat field with space as field:value", () => {
      const result = tokenize("field name:value");
      expect(result).toEqual([
        { type: "string", value: "field" },
        { type: "field_value", field: "name", value: "value" },
      ]);
    });

    it("should not treat field with quote as field:value", () => {
      const result = tokenize('"field":value');
      expect(result).toEqual([
        { type: "string", value: "field" },
        { type: "string", value: ":value" },
      ]);
    });

    it("should handle numeric field names", () => {
      const result = tokenize("123:value");
      expect(result).toEqual([
        { type: "field_value", field: "123", value: "value" },
      ]);
    });

    it("should handle field names with only underscores", () => {
      const result = tokenize("_:value");
      expect(result).toEqual([
        { type: "field_value", field: "_", value: "value" },
      ]);
    });
  });

  describe("quote handling", () => {
    it("should prefer matching quote character", () => {
      const result = tokenize('"hello world"');
      expect(result[0].type).toBe("string");
      expect(result[0].type === "string" && result[0].value).toBe(
        "hello world",
      );
    });

    it("should handle nested different quote types", () => {
      const result = tokenize(`'he said "hello"'`);
      expect(result).toEqual([{ type: "string", value: 'he said "hello"' }]);
    });

    it("should handle quote at end of unquoted value", () => {
      const result = tokenize('test"');
      expect(result).toEqual([{ type: "string", value: 'test"' }]);
    });

    it("should handle multiple quotes in sequence", () => {
      const result = tokenize('""""""');
      expect(result).toHaveLength(3); // Three empty strings
      expect(result).toEqual([
        { type: "string", value: "" },
        { type: "string", value: "" },
        { type: "string", value: "" },
      ]);
    });
  });
});
