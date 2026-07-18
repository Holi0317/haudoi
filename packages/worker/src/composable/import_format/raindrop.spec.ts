import { describe, expect, it } from "vitest";
import { parseFormat } from "./index";

function csv(header: string, ...rows: string[]): string {
  return [header, ...rows].join("\n");
}

describe("parseRaindropCsv", () => {
  const header =
    "id,title,note,excerpt,url,folder,tags,created,cover,highlights,favorite";

  it("parses unsorted (unread) items", () => {
    const body = csv(
      header,
      "1,My Bookmark,,,https://example.com/bookmark,Unsorted,dev,2023-01-15T10:30:00.000Z,,,false",
      "2,Another One,A note here,An excerpt,https://example.com/another,Unsorted,design,2023-02-20T14:00:00.000Z,,,false",
    );

    const { items, errors } = parseFormat("raindrop", body);
    expect(errors).toHaveLength(0);
    expect(items).toHaveLength(2);

    expect(items[0]).toMatchObject({
      title: "My Bookmark",
      url: "https://example.com/bookmark",
      archive: false,
      favorite: false,
      note: expect.stringContaining("dev") as string,
    });

    expect(items[1].title).toBe("Another One");
    expect(items[1].archive).toBe(false);
    expect(items[1].note).toContain("A note here");
    expect(items[1].note).not.toContain("An excerpt");
  });

  it("parses archived items with folder 'archive'", () => {
    const body = csv(
      header,
      "3,Archived Link,,,https://example.com/archived,archive,,2023-03-10T08:00:00.000Z,,,false",
      "4,Saved Read,My notes,,https://example.com/saved,archive,toread,2023-04-01T12:00:00.000Z,,,false",
    );

    const { items, errors } = parseFormat("raindrop", body);
    expect(errors).toHaveLength(0);
    expect(items).toHaveLength(2);

    expect(items[0].archive).toBe(true);
    expect(items[0].title).toBe("Archived Link");

    expect(items[1].archive).toBe(true);
    expect(items[1].title).toBe("Saved Read");
  });

  it("maps favorite 'true' to favorite: true", () => {
    const body = csv(
      header,
      "5,Fav Link,,,https://example.com/fav,Unsorted,,2023-05-01T00:00:00.000Z,,,true",
      "6,Not Fav,,,https://example.com/nope,archive,,2023-05-02T00:00:00.000Z,,,false",
    );

    const { items } = parseFormat("raindrop", body);
    expect(items[0].favorite).toBe(true);
    expect(items[1].favorite).toBe(false);
  });

  it("combines note and tags into the note field (excerpt is dropped)", () => {
    const body = csv(
      header,
      "7,Full Entry,Detailed notes,Short excerpt,https://example.com/full,Unsorted,ai ml,2023-06-01T00:00:00.000Z,,,false",
    );

    const { items } = parseFormat("raindrop", body);
    const note = items[0].note;
    expect(note).toContain("[Imported]");
    expect(note).toContain("tags: ai ml");
    expect(note).toContain("Detailed notes");
    expect(note).not.toContain("Short excerpt");
  });

  it("handles empty note, excerpt, and tags", () => {
    const body = csv(
      header,
      "8,Minimal,,,https://example.com/min,Unsorted,,2023-07-01T00:00:00.000Z,,,false",
    );

    const { items } = parseFormat("raindrop", body);
    expect(items[0].note).toBe("[Imported]");
    expect(items[0].archive).toBe(false);
  });

  it("handles missing optional fields gracefully", () => {
    const body = csv(
      header,
      "9,Partial,Some note,,https://example.com/partial,Unsorted,,2023-08-01T00:00:00.000Z,,,",
    );

    const { items } = parseFormat("raindrop", body);
    expect(items[0].title).toBe("Partial");
    expect(items[0].note).toContain("Some note");
    expect(items[0].favorite).toBe(false);
  });

  it("preserves created_at timestamp from ISO 8601", () => {
    const body = csv(
      header,
      "10,Dated,,,https://example.com/dated,Unsorted,,2024-01-15T10:30:00.000Z,,,false",
    );

    const { items } = parseFormat("raindrop", body);
    const d = new Date(2024, 0, 15, 10, 30, 0, 0);
    expect(items[0].created_at).toBe(d.getTime());
  });
});
