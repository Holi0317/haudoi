import { describe, expect, it } from "vitest";
import * as zu from "../src/zod-utils";

describe("queryBool", () => {
  it("should parse simple values", () => {
    const schema = zu.queryBool();

    const truthy = ["true", "on", "ON", "TRUE"];
    const falsy = ["false", "off", "OFF"];

    for (const t of truthy) {
      expect(schema.safeDecode(t)).toEqual({
        success: true,
        data: true,
      });
    }

    for (const f of falsy) {
      expect(schema.safeDecode(f)).toEqual({
        success: true,
        data: false,
      });
    }
  });

  it("should treat empty string as undefined", () => {
    const schema = zu.queryBool();

    expect(schema.safeDecode("")).toEqual({
      success: true,
      data: undefined,
    });
  });
});

describe("queryString", () => {
  const schema = zu.queryString();

  it("should default to '?'", () => {
    expect(schema.parse(undefined)).toEqual("");
  });

  it("should default empty string to '?'", () => {
    expect(schema.parse("")).toEqual("");
  });

  it("should accept valid query string", () => {
    expect(schema.parse("?foo=bar")).toEqual("?foo=bar");
  });

  it("should reject query string that does not start with '?'", () => {
    expect(schema.safeParse("aaaa").success).toEqual(false);
  });

  it("should reject query string that is too long", () => {
    expect(schema.safeParse("a".repeat(2001)).success).toEqual(false);
  });
});

describe("checkboxBool", () => {
  const schema = zu.checkboxBool();

  it('should treat "on" as true', () => {
    expect(schema.parse("on")).toEqual(true);
  });

  it("should treat undefined as false", () => {
    expect(schema.parse(undefined)).toEqual(false);
  });

  it("should treat other string values as false", () => {
    expect(schema.parse("whatever")).toEqual(false);
  });
});

describe("httpUrl", () => {
  const schema = zu.httpUrl();

  it("should reject non-http/https urls", () => {
    expect(schema.safeDecode("http://example.com").success).toEqual(true);
    expect(schema.safeDecode("https://example.com").success).toEqual(true);

    expect(schema.safeDecode("ftp://example.com").success).toEqual(false);
  });

  it("should accept valid http and https urls", () => {
    const validUrls = [
      "http://example.com",
      "https://example.com",
      "http://subdomain.example.com",
      "https://example.com/path",
      "http://example.com/path/to/page",
    ];

    for (const url of validUrls) {
      const result = schema.safeDecode(url);
      expect(result.success).toEqual(true);
    }
  });

  it("should remove hash fragments", () => {
    const result = schema.safeDecode("http://example.com/page#section");

    expect(result).toEqual({
      success: true,
      data: "http://example.com/page",
    });
  });

  it("should remove authentication info", () => {
    const result = schema.safeDecode("http://user:password@example.com/path");

    expect(result).toEqual({
      success: true,
      data: "http://example.com/path",
    });
  });

  it("should remove tracking parameters", () => {
    const trackingParamUrls = [
      "http://example.com?utm_source=google&utm_medium=social",
      "http://example.com?utm_medium=social",
      "http://example.com?utm_campaign=test",
      "http://example.com?utm_term=keyword",
      "http://example.com?utm_content=ad",
      "http://example.com?si=123",
      "http://example.com?igshid=456",
    ];

    for (const url of trackingParamUrls) {
      const result = schema.safeDecode(url);
      expect(result).toEqual({
        success: true,
        data: "http://example.com/",
      });
    }
  });

  it("should keep non-tracking query parameters", () => {
    // Also make sure multiple same keys are preserved
    const result = schema.safeDecode(
      "http://example.com?page=1&page=3&search=test",
    );
    expect(result).toEqual({
      success: true,
      data: "http://example.com/?page=1&page=3&search=test",
    });
  });

  it("should sort query parameters alphabetically", () => {
    const result = schema.safeDecode(
      "http://example.com?zebra=1&apple=2&banana=3",
    );
    expect(result).toEqual({
      success: true,
      data: "http://example.com/?apple=2&banana=3&zebra=1",
    });
  });

  it("should remove tracking parameters while keeping other parameters", () => {
    const result = schema.safeDecode(
      "http://example.com?page=1&utm_source=google&search=test&igshid=123",
    );
    expect(result).toEqual({
      success: true,
      data: "http://example.com/?page=1&search=test",
    });
  });

  it("should normalize URLs", () => {
    const result = schema.safeDecode("http://example.com");
    expect(result).toEqual({
      success: true,
      data: "http://example.com/",
    });
  });

  it("should reject invalid URLs", () => {
    const invalidUrls = ["not a url", "example.com", "javascript:alert('xss')"];

    for (const url of invalidUrls) {
      const result = schema.safeDecode(url);
      expect(result.success).toEqual(false);
    }
  });

  it("should handle complex URLs with all transformations", () => {
    const result = schema.safeDecode(
      "http://user:pass@example.com/path?zebra=1&utm_source=google&apple=2#section",
    );

    expect(result).toEqual({
      success: true,
      data: "http://example.com/path?apple=2&zebra=1",
    });
  });
});
