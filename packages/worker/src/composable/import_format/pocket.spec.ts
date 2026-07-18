import { describe, expect, it } from "vitest";
import { parsePocketCsv } from "./pocket";

function csv(header: string, ...rows: string[]): string {
  return [header, ...rows].join("\n");
}

describe("parsePocketCsv", () => {
  const header = "title,url,time_added,tags,status";

  it("parses unread items", () => {
    const body = csv(
      header,
      "My Article,https://example.com/article,1562592000,news,unread",
      "Another Post,https://example.com/post,1562678400,tech,unread",
    );

    const { items, errors } = parsePocketCsv(body);
    expect(errors).toHaveLength(0);
    expect(items).toHaveLength(2);

    expect(items[0]).toMatchObject({
      title: "My Article",
      url: "https://example.com/article",
      archive: false,
      favorite: false,
      note: expect.stringContaining("[Imported]") as string,
    });
    expect(items[0].created_at).toBeGreaterThan(0);

    expect(items[1].title).toBe("Another Post");
    expect(items[1].archive).toBe(false);
  });

  it("parses archived items", () => {
    const body = csv(
      header,
      "Old Article,https://example.com/old,1560000000,,archive",
      "Saved Page,https://example.com/saved,1560086400,,archive",
    );

    const { items, errors } = parsePocketCsv(body);
    expect(errors).toHaveLength(0);
    expect(items).toHaveLength(2);

    expect(items[0].archive).toBe(true);
    expect(items[0].title).toBe("Old Article");

    expect(items[1].archive).toBe(true);
    expect(items[1].title).toBe("Saved Page");
  });

  it("includes tags in note", () => {
    const body = csv(
      header,
      "Tagged,https://example.com/tagged,1562592000,tech news,unread",
    );

    const { items } = parsePocketCsv(body);
    expect(items[0].note).toContain("[Imported]");
    expect(items[0].note).toContain("tags: tech news");
  });

  it("handles empty tags", () => {
    const body = csv(
      header,
      "No Tags,https://example.com/notags,1562592000,,unread",
    );

    const { items } = parsePocketCsv(body);
    expect(items[0].note).toContain("[Imported]");
    expect(items[0].note).toContain("tags:");
  });
});
