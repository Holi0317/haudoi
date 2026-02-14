import { fetchMock } from "cloudflare:test";
import type * as z from "zod";
import { describe, it, expect, beforeAll, afterEach } from "vitest";
import type { InferRequestType, InferResponseType } from "hono/client";
import type { CursorPayload } from "../src/composable/cursor";
import { decodeCursor, encodeCursor } from "../src/composable/cursor";
import type { ClientType } from "../src/client";
import { createTestClient } from "./client";
import type { InsertSchema } from "../src/schemas";

interface TestCase {
  insert: Array<z.input<typeof InsertSchema>>;

  search: InferRequestType<ClientType["api"]["search"]["$get"]>["query"];

  edit?: InferRequestType<ClientType["api"]["edit"]["$post"]>["json"]["op"];

  resp: Omit<
    InferResponseType<ClientType["api"]["search"]["$get"]>,
    "cursor"
  > & {
    cursor: CursorPayload | null;
  };
}

async function testInsert(tc: TestCase) {
  const client = await createTestClient();

  if (tc.insert.length > 0) {
    const insert = await client.api.edit.$post({
      json: {
        op: tc.insert.map((item) => ({ op: "insert", ...item })),
      },
    });

    expect(insert.status).toEqual(201);
  }

  const edit = tc.edit ?? [];
  if (edit.length > 0) {
    const ed = await client.api.edit.$post({
      json: {
        op: edit,
      },
    });

    expect(ed.status).toEqual(201);
  }

  const search = await client.api.search.$get({
    query: tc.search,
  });

  expect(search.status).toEqual(200);
  const j = await search.json();
  expect({
    ...j,
    cursor: decodeCursor(j.cursor),
  }).toEqual(tc.resp);
}

describe("Link search", () => {
  beforeAll(() => {
    fetchMock.activate();
    fetchMock.disableNetConnect();
  });

  afterEach(() => fetchMock.assertNoPendingInterceptors());

  it("should return nothing on empty db", async () => {
    await testInsert({
      insert: [],
      search: {},
      resp: {
        count: 0,
        cursor: null,
        hasMore: false,
        items: [],
      },
    });
  });

  it("should list result", async () => {
    await testInsert({
      insert: [
        { url: "http://1.com", title: "1" },
        { url: "http://2.com", title: "2" },
        { url: "http://3.com", title: "3" },
      ],
      search: {},
      resp: {
        count: 3,
        cursor: null,
        hasMore: false,
        items: [
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 3,
            title: "3",
            url: "http://3.com/",
            note: "",
            tags: [],
          },
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 2,
            title: "2",
            url: "http://2.com/",
            note: "",
            tags: [],
          },
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 1,
            title: "1",
            url: "http://1.com/",
            note: "",
            tags: [],
          },
        ],
      },
    });
  });

  it("should return empty if search query doesn't match anything", async () => {
    await testInsert({
      insert: [
        { url: "http://1.com", title: "1" },
        { url: "http://2.com", title: "2" },
        { url: "http://3.com", title: "3" },
      ],
      search: {
        query: "foo",
      },
      resp: {
        count: 0,
        cursor: null,
        hasMore: false,
        items: [],
      },
    });
  });

  it("should search by title", async () => {
    await testInsert({
      insert: [
        { url: "http://1.com", title: "one" },
        { url: "http://2.com", title: "two" },
        { url: "http://3.com", title: "three" },
      ],
      search: {
        query: "1",
      },
      resp: {
        count: 1,
        cursor: null,
        hasMore: false,
        items: [
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 1,
            title: "one",
            url: "http://1.com/",
            note: "",
            tags: [],
          },
        ],
      },
    });
  });

  it("should search by url", async () => {
    await testInsert({
      insert: [
        { url: "http://example.com/aaaa", title: "one" },
        { url: "http://example.com/bbbb", title: "two" },
        { url: "http://3.com", title: "three" },
      ],
      search: {
        query: "example.com",
      },
      resp: {
        count: 2,
        cursor: null,
        hasMore: false,
        items: [
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 2,
            title: "two",
            url: "http://example.com/bbbb",
            note: "",
            tags: [],
          },
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 1,
            title: "one",
            url: "http://example.com/aaaa",
            note: "",
            tags: [],
          },
        ],
      },
    });
  });

  it("should search by note", async () => {
    await testInsert({
      insert: [
        { url: "http://example.com/aaaa", title: "one" },
        { url: "http://example.com/bbbb", title: "two" },
        { url: "http://3.com", title: "three" },
      ],
      edit: [
        {
          op: "set_string",
          id: 1,
          field: "note",
          value: "this is an example note",
        },
        { op: "set_string", id: 2, field: "note", value: "another note" },
      ],
      search: {
        query: "Another",
      },
      resp: {
        count: 1,
        cursor: null,
        hasMore: false,
        items: [
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 2,
            title: "two",
            url: "http://example.com/bbbb",
            note: "another note",
            tags: [],
          },
        ],
      },
    });
  });

  it("sorting should work", async () => {
    await testInsert({
      insert: [
        // A bit confusing, but created_at is in descending order here.
        // Expect the response to reverse this order.
        { url: "http://3.com", title: "3", created_at: 1620000000003 },
        { url: "http://2.com", title: "2", created_at: 1620000000002 },
        { url: "http://1.com", title: "1", created_at: 1620000000001 },
      ],
      search: {
        order: "created_at_asc",
      },
      resp: {
        count: 3,
        cursor: null,
        hasMore: false,
        items: [
          {
            archive: false,
            created_at: 1620000000001,
            favorite: false,
            id: 3,
            title: "1",
            url: "http://1.com/",
            note: "",
            tags: [],
          },
          {
            archive: false,
            created_at: 1620000000002,
            favorite: false,
            id: 2,
            title: "2",
            url: "http://2.com/",
            note: "",
            tags: [],
          },
          {
            archive: false,
            created_at: 1620000000003,
            favorite: false,
            id: 1,
            title: "3",
            url: "http://3.com/",
            note: "",
            tags: [],
          },
        ],
      },
    });
  });

  it("limit, cursor and tie breaking should work", async () => {
    await testInsert({
      insert: [
        { url: "http://1.com", title: "1", created_at: 1620000000000 },
        { url: "http://2.com", title: "2", created_at: 1620000000000 },
        { url: "http://3.com", title: "3", created_at: 1620000000000 },
      ],
      search: {
        limit: "1",
        cursor: encodeCursor({ id: 1, created_at: 1620000000000 }),
        order: "created_at_asc",
      },
      resp: {
        count: 3,
        cursor: { id: 2, created_at: expect.any(Number) },
        hasMore: true,
        items: [
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 2,
            title: "2",
            url: "http://2.com/",
            note: "",
            tags: [],
          },
        ],
      },
    });
  });

  it("should ignore cursor if it's invalid", async () => {
    await testInsert({
      insert: [
        { url: "http://1.com", title: "1", created_at: 1620000000000 },
        { url: "http://2.com", title: "2", created_at: 1620000000000 },
        { url: "http://3.com", title: "3", created_at: 1620000000000 },
      ],
      search: {
        limit: "1",
        cursor: "asdf",
      },
      resp: {
        count: 3,
        cursor: {
          id: 3,
          created_at: expect.any(Number),
        },
        hasMore: true,
        items: [
          {
            archive: false,
            created_at: expect.any(Number),
            favorite: false,
            id: 3,
            title: "3",
            url: "http://3.com/",
            note: "",
            tags: [],
          },
        ],
      },
    });
  });

  it("should work on complex query pattern", async () => {
    await testInsert({
      insert: [],
      search: {
        // There's this "Maximum characters (bytes) in a LIKE or GLOB pattern" limit on durable object.
        // See https://developers.cloudflare.com/durable-objects/platform/limits/#sql-storage-limits
        // This is to make sure we are using substring-based search method, or at least
        // substring search won't blow up on long query string.
        query:
          "1b23827ff2fdd972040369f40878bdb7f0256c5ee759dec7b9cc88d38391f1b2",
      },
      resp: {
        count: 0,
        cursor: null,
        hasMore: false,
        items: [],
      },
    });
  });
});
