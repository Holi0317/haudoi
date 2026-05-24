import type * as z from "zod";
import { describe, it, expect } from "vitest";
import { HttpResponse, http } from "msw";
import { server, trackOneOffInterceptor } from "./server";
import { createTestClient } from "./client";
import type { InsertSchema, LinkItemWithTags } from "../src/schemas";

function mockGoogleGet(
  path: string,
  status: number,
  body?: BodyInit | null,
  headers?: HeadersInit,
) {
  server.use(
    http.get(
      `https://google.com${path}`,
      trackOneOffInterceptor(() => {
        return new HttpResponse(body ?? null, { status, headers });
      }),
      { once: true },
    ),
  );
}

describe("Link insert", () => {
  interface TestCase {
    insert: Array<z.input<typeof InsertSchema>>;

    insertResponse: LinkItemWithTags[];
  }

  async function testInsert(tc: TestCase) {
    const client = await createTestClient();

    const insert = await client.api.edit.$post({
      json: {
        op: tc.insert.map((item) => ({ op: "insert", ...item })),
      },
    });

    expect(insert.status).toEqual(201);

    const search = await client.api.search.$get({ query: {} });
    expect(search.status).toEqual(200);
    const j = await search.json();
    expect(j.items).toEqual(tc.insertResponse);
  }

  it("should insert link and store it", async () => {
    await testInsert({
      insert: [{ title: "asdf", url: "https://google.com" }],
      insertResponse: [
        {
          id: 1,
          title: "asdf",
          url: "https://google.com/",
          archive: false,
          favorite: false,
          created_at: expect.any(Number),
          note: "",
          tags: [],
        },
      ],
    });
  });

  it("should use document title when http response isn't ok", async () => {
    mockGoogleGet(
      "/",
      404,
      `<!doctype html><html><head><title>You should still use this 404 title</title></head></html>`,
    );

    await testInsert({
      insert: [{ title: "", url: "https://google.com" }],
      insertResponse: [
        {
          id: 1,
          title: "You should still use this 404 title",
          url: "https://google.com/",
          archive: false,
          favorite: false,
          created_at: expect.any(Number),
          note: "",
          tags: [],
        },
      ],
    });
  });

  it("should use empty string as title if document fetch failed", async () => {
    mockGoogleGet("/", 500, "boom");

    await testInsert({
      insert: [{ title: "", url: "https://google.com" }],
      insertResponse: [
        {
          id: 1,
          title: "",
          url: "https://google.com/",
          archive: false,
          favorite: false,
          created_at: expect.any(Number),
          note: "",
          tags: [],
        },
      ],
    });
  });

  it("should deduplicate same URL in different request", async () => {
    await testInsert({
      insert: [{ title: "first", url: "https://google.com" }],
      insertResponse: [
        {
          id: 1,
          title: "first",
          url: "https://google.com/",
          archive: false,
          favorite: false,
          created_at: expect.any(Number),
          note: "",
          tags: [],
        },
      ],
    });

    await testInsert({
      insert: [{ title: "second", url: "https://google.com" }],
      insertResponse: [
        {
          id: 2,
          title: "second",
          url: "https://google.com/",
          archive: false,
          favorite: false,
          created_at: expect.any(Number),
          note: "",
          tags: [],
        },
      ],
    });
  });

  it("should deduplicate same URL in same request", async () => {
    await testInsert({
      insert: [
        // Also testing dedupe is after cleaning the url
        { title: "first", url: "https://google.com#123" },
        { title: "second", url: "https://google.com#456" },
      ],
      insertResponse: [
        {
          id: 2,
          title: "second",
          url: "https://google.com/",
          archive: false,
          favorite: false,
          created_at: expect.any(Number),
          note: "",
          tags: [],
        },
      ],
    });
  });

  it("should remove hash, username and password from URL", async () => {
    await testInsert({
      insert: [
        {
          title: "asdf",
          url: "https://username:password@google.com?query=123&query=456#hash",
        },
      ],
      insertResponse: [
        {
          id: 1,
          title: "asdf",
          url: "https://google.com/?query=123&query=456",
          archive: false,
          favorite: false,
          created_at: expect.any(Number),
          note: "",
          tags: [],
        },
      ],
    });
  });

  it("should remove tracking query", async () => {
    await testInsert({
      insert: [
        {
          title: "asdf",
          url: "https://google.com?utm_content=buffercf3b2&utm_medium=social&utm_source=snapchat.com&utm_campaign=buffer",
        },
      ],
      insertResponse: [
        {
          id: 1,
          title: "asdf",
          url: "https://google.com/",
          archive: false,
          favorite: false,
          created_at: expect.any(Number),
          note: "",
          tags: [],
        },
      ],
    });
  });

  it("should write archive/favorite/note fields", async () => {
    await testInsert({
      insert: [
        {
          title: "Test with all fields",
          url: "https://example.com",
          archive: true,
          favorite: true,
          note: "This is a test note",
        },
      ],
      insertResponse: [
        {
          id: 1,
          title: "Test with all fields",
          url: "https://example.com/",
          archive: true,
          favorite: true,
          note: "This is a test note",
          created_at: expect.any(Number),
          tags: [],
        },
      ],
    });
  });

  it("should write created_at timestamp", async () => {
    await testInsert({
      insert: [
        {
          title: "Test with custom timestamp",
          url: "https://example.com",
          created_at: 1620000000000,
        },
      ],
      insertResponse: [
        {
          id: 1,
          title: "Test with custom timestamp",
          url: "https://example.com/",
          archive: false,
          favorite: false,
          note: "",
          created_at: 1620000000000,
          tags: [],
        },
      ],
    });
  });
});

describe("HTML title scraping", () => {
  interface TestCase {
    title: string;
    document?: string;
    expected: string;
  }

  async function testInsert(tc: TestCase) {
    const doc =
      tc.document ??
      `<!doctype html><html><head><title>${tc.title}</title></head></html>`;

    mockGoogleGet("/", 200, doc);

    const client = await createTestClient();

    const insert = await client.api.edit.$post({
      json: {
        op: [{ op: "insert", title: "", url: "https://google.com" }],
      },
    });
    expect(insert.status).toEqual(201);

    const search = await client.api.search.$get({ query: {} });
    expect(search.status).toEqual(200);

    const j = await search.json();

    expect(j.items).toEqual([
      {
        id: 1,
        title: tc.expected,
        url: "https://google.com/",
        created_at: expect.any(Number),
        favorite: false,
        note: "",
        archive: false,
        tags: [],
      },
    ]);
  }

  it("should fetch title from document", async () => {
    await testInsert({
      title: "My cute title",
      expected: "My cute title",
    });
  });

  it("should unescape html entity", async () => {
    await testInsert({
      title: "Hash &#35; and &amp; lt &lt; lt &#60;",
      expected: "Hash # and & lt < lt <",
    });
  });

  it("should trim excessive whitespace", async () => {
    await testInsert({
      title: `     


Hello


w

      

`,
      expected: "Hello\n\n\nw",
    });
  });

  it("should only use title in head", async () => {
    await testInsert({
      title: "",
      document: `<!doctype html><html><head><title>true title</title></head><body><title>No</title></body></html>`,
      expected: "true title",
    });
  });
});
