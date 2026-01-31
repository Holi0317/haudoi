import { fetchMock } from "cloudflare:test";
import { describe, it, expect, beforeAll, afterEach } from "vitest";
import { createTestClient } from "./client";

describe("Tag CRUD", () => {
  beforeAll(() => {
    fetchMock.activate();
    fetchMock.disableNetConnect();
  });

  afterEach(() => fetchMock.assertNoPendingInterceptors());

  it("should list empty tags initially", async () => {
    const client = await createTestClient();

    const resp = await client.api.tags.$get();
    expect(resp.status).toEqual(200);

    const body = await resp.json();
    expect(body.tags).toEqual([]);
  });

  it("should create a new tag", async () => {
    const client = await createTestClient();

    const resp = await client.api.tags.$post({
      json: {
        name: "Important",
        color: "#FF5733",
      },
    });

    expect(resp.status).toEqual(201);
    const body = await resp.json();
    expect(body.tag).toEqual({
      id: 1,
      name: "Important",
      color: "#FF5733",
    });
  });

  it("should list created tags", async () => {
    const client = await createTestClient();

    // Create two tags
    await client.api.tags.$post({
      json: { name: "Work", color: "#0000FF" },
    });
    await client.api.tags.$post({
      json: { name: "Personal", color: "#00FF00" },
    });

    const resp = await client.api.tags.$get();
    expect(resp.status).toEqual(200);

    const body = await resp.json();
    expect(body.tags).toEqual([
      { id: 1, name: "Work", color: "#0000FF" },
      { id: 2, name: "Personal", color: "#00FF00" },
    ]);
  });

  it("should get a tag by ID", async () => {
    const client = await createTestClient();

    await client.api.tags.$post({
      json: { name: "MyTag", color: "#ABCDEF" },
    });

    const resp = await client.api.tags[":id"].$get({
      param: { id: "1" },
    });

    expect(resp.status).toEqual(200);
    const body = await resp.json();
    expect(body.tag).toEqual({
      id: 1,
      name: "MyTag",
      color: "#ABCDEF",
    });
  });

  it("should return 404 for non-existent tag", async () => {
    const client = await createTestClient();

    const resp = await client.api.tags[":id"].$get({
      param: { id: "999" },
    });

    expect(resp.status).toEqual(404);
  });

  it("should update a tag name", async () => {
    const client = await createTestClient();

    await client.api.tags.$post({
      json: { name: "OldName", color: "#123456" },
    });

    const resp = await client.api.tags[":id"].$patch({
      param: { id: "1" },
      json: { name: "NewName" },
    });

    expect(resp.status).toEqual(200);
    const body = await resp.json();
    expect(body.tag).toEqual({
      id: 1,
      name: "NewName",
      color: "#123456",
    });
  });

  it("should update a tag color", async () => {
    const client = await createTestClient();

    await client.api.tags.$post({
      json: { name: "Colorful", color: "#111111" },
    });

    const resp = await client.api.tags[":id"].$patch({
      param: { id: "1" },
      json: { color: "#999999" },
    });

    expect(resp.status).toEqual(200);
    const body = await resp.json();
    expect(body.tag).toEqual({
      id: 1,
      name: "Colorful",
      color: "#999999",
    });
  });

  it("should delete a tag", async () => {
    const client = await createTestClient();

    await client.api.tags.$post({
      json: { name: "ToDelete", color: "#AABBCC" },
    });

    const deleteResp = await client.api.tags[":id"].$delete({
      param: { id: "1" },
    });
    expect(deleteResp.status).toEqual(200);

    // Verify tag is gone
    const getResp = await client.api.tags[":id"].$get({
      param: { id: "1" },
    });
    expect(getResp.status).toEqual(404);
  });

  it("should prevent duplicate tag names (case-insensitive)", async () => {
    const client = await createTestClient();

    // Create first tag
    const resp1 = await client.api.tags.$post({
      json: { name: "Duplicate", color: "#111111" },
    });
    expect(resp1.status).toEqual(201);

    // Try to create same tag with different case
    const resp2 = await client.api.tags.$post({
      json: { name: "DUPLICATE", color: "#222222" },
    });
    expect(resp2.status).toEqual(409);

    // Also lowercase
    const resp3 = await client.api.tags.$post({
      json: { name: "duplicate", color: "#333333" },
    });
    expect(resp3.status).toEqual(409);
  });

  it("should validate tag color format", async () => {
    const client = await createTestClient();

    // Invalid color format
    const resp = await client.api.tags.$post({
      json: { name: "BadColor", color: "red" },
    });

    expect(resp.status).toEqual(400);
  });
});

describe("Link tagging", () => {
  beforeAll(() => {
    fetchMock.activate();
    fetchMock.disableNetConnect();
  });

  afterEach(() => fetchMock.assertNoPendingInterceptors());

  it("should add tag to link", async () => {
    const client = await createTestClient();

    // Create a link
    await client.api.edit.$post({
      json: {
        op: [{ op: "insert", url: "http://example.com", title: "Example" }],
      },
    });

    // Create a tag
    await client.api.tags.$post({
      json: { name: "Test", color: "#FF0000" },
    });

    // Add tag to link
    const editResp = await client.api.edit.$post({
      json: {
        op: [{ op: "add_tag", id: 1, tagId: 1 }],
      },
    });
    expect(editResp.status).toEqual(201);

    // Search with includeTags
    const searchResp = await client.api.search.$get({
      query: { includeTags: "true" },
    });
    expect(searchResp.status).toEqual(200);

    const body = await searchResp.json();
    expect(body.items[0].tags).toEqual([1]);
  });

  it("should remove tag from link", async () => {
    const client = await createTestClient();

    // Create a link
    await client.api.edit.$post({
      json: {
        op: [{ op: "insert", url: "http://example.com", title: "Example" }],
      },
    });

    // Create a tag
    await client.api.tags.$post({
      json: { name: "Test", color: "#FF0000" },
    });

    // Add tag to link
    await client.api.edit.$post({
      json: {
        op: [{ op: "add_tag", id: 1, tagId: 1 }],
      },
    });

    // Remove tag from link
    const editResp = await client.api.edit.$post({
      json: {
        op: [{ op: "remove_tag", id: 1, tagId: 1 }],
      },
    });
    expect(editResp.status).toEqual(201);

    // Search with includeTags - should be empty
    const searchResp = await client.api.search.$get({
      query: { includeTags: "true" },
    });
    expect(searchResp.status).toEqual(200);

    const body = await searchResp.json();
    expect(body.items[0].tags).toEqual([]);
  });

  it("should filter by tag", async () => {
    const client = await createTestClient();

    // Create links
    await client.api.edit.$post({
      json: {
        op: [
          { op: "insert", url: "http://1.com", title: "One" },
          { op: "insert", url: "http://2.com", title: "Two" },
          { op: "insert", url: "http://3.com", title: "Three" },
        ],
      },
    });

    // Create tags
    await client.api.tags.$post({
      json: { name: "TagA", color: "#AA0000" },
    });
    await client.api.tags.$post({
      json: { name: "TagB", color: "#BB0000" },
    });

    // Tag link 1 and 2 with TagA
    await client.api.edit.$post({
      json: {
        op: [
          { op: "add_tag", id: 1, tagId: 1 },
          { op: "add_tag", id: 2, tagId: 1 },
        ],
      },
    });

    // Tag link 2 with TagB too
    await client.api.edit.$post({
      json: {
        op: [{ op: "add_tag", id: 2, tagId: 2 }],
      },
    });

    // Filter by TagA - should return link 1 and 2
    const searchA = await client.api.search.$get({
      query: { tag: "1", order: "created_at_asc" },
    });
    expect(searchA.status).toEqual(200);
    const bodyA = await searchA.json();
    expect(bodyA.count).toEqual(2);
    expect(bodyA.items.map((i) => i.id)).toEqual([1, 2]);

    // Filter by TagB - should return only link 2
    const searchB = await client.api.search.$get({
      query: { tag: "2" },
    });
    expect(searchB.status).toEqual(200);
    const bodyB = await searchB.json();
    expect(bodyB.count).toEqual(1);
    expect(bodyB.items[0].id).toEqual(2);

    // No tag filter - should return all 3
    const searchAll = await client.api.search.$get({
      query: {},
    });
    expect(searchAll.status).toEqual(200);
    const bodyAll = await searchAll.json();
    expect(bodyAll.count).toEqual(3);
  });

  it("should handle multiple tags on same link", async () => {
    const client = await createTestClient();

    // Create a link
    await client.api.edit.$post({
      json: {
        op: [
          { op: "insert", url: "http://example.com", title: "Multi-tagged" },
        ],
      },
    });

    // Create multiple tags
    await client.api.tags.$post({
      json: { name: "Tag1", color: "#110000" },
    });
    await client.api.tags.$post({
      json: { name: "Tag2", color: "#220000" },
    });
    await client.api.tags.$post({
      json: { name: "Tag3", color: "#330000" },
    });

    // Add all tags to link
    await client.api.edit.$post({
      json: {
        op: [
          { op: "add_tag", id: 1, tagId: 1 },
          { op: "add_tag", id: 1, tagId: 2 },
          { op: "add_tag", id: 1, tagId: 3 },
        ],
      },
    });

    // Search with includeTags
    const searchResp = await client.api.search.$get({
      query: { includeTags: "true" },
    });
    expect(searchResp.status).toEqual(200);

    const body = await searchResp.json();
    expect(body.items[0].tags).toHaveLength(3);
    expect(body.items[0].tags).toContain(1);
    expect(body.items[0].tags).toContain(2);
    expect(body.items[0].tags).toContain(3);
  });

  it("should silently handle adding same tag twice", async () => {
    const client = await createTestClient();

    // Create a link
    await client.api.edit.$post({
      json: {
        op: [{ op: "insert", url: "http://example.com", title: "Example" }],
      },
    });

    // Create a tag
    await client.api.tags.$post({
      json: { name: "Test", color: "#FF0000" },
    });

    // Add tag twice
    const editResp = await client.api.edit.$post({
      json: {
        op: [
          { op: "add_tag", id: 1, tagId: 1 },
          { op: "add_tag", id: 1, tagId: 1 }, // duplicate - should be ignored
        ],
      },
    });
    expect(editResp.status).toEqual(201);

    // Should only have one tag
    const searchResp = await client.api.search.$get({
      query: { includeTags: "true" },
    });
    const body = await searchResp.json();
    expect(body.items[0].tags).toEqual([1]);
  });

  it("should remove tags when link is deleted", async () => {
    const client = await createTestClient();

    // Create a link
    await client.api.edit.$post({
      json: {
        op: [{ op: "insert", url: "http://example.com", title: "ToDelete" }],
      },
    });

    // Create and add a tag
    await client.api.tags.$post({
      json: { name: "Orphan", color: "#FF0000" },
    });
    await client.api.edit.$post({
      json: {
        op: [{ op: "add_tag", id: 1, tagId: 1 }],
      },
    });

    // Delete the link
    await client.api.edit.$post({
      json: {
        op: [{ op: "delete", id: 1 }],
      },
    });

    // Tag should still exist
    const tagResp = await client.api.tags[":id"].$get({
      param: { id: "1" },
    });
    expect(tagResp.status).toEqual(200);
  });

  it("should remove link-tag associations when tag is deleted", async () => {
    const client = await createTestClient();

    // Create a link
    await client.api.edit.$post({
      json: {
        op: [{ op: "insert", url: "http://example.com", title: "Example" }],
      },
    });

    // Create and add a tag
    await client.api.tags.$post({
      json: { name: "ToDelete", color: "#FF0000" },
    });
    await client.api.edit.$post({
      json: {
        op: [{ op: "add_tag", id: 1, tagId: 1 }],
      },
    });

    // Delete the tag
    await client.api.tags[":id"].$delete({
      param: { id: "1" },
    });

    // Link should still exist but have no tags
    const searchResp = await client.api.search.$get({
      query: { includeTags: "true" },
    });
    expect(searchResp.status).toEqual(200);
    const body = await searchResp.json();
    expect(body.items[0].tags).toEqual([]);
  });
});
