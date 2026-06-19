import { describe, it, expect } from "vitest";
import { createTestClient } from "./client";

describe("Test client", () => {
  it("should get authenticated successfully", async () => {
    const client = await createTestClient();

    const response = await client.api.$get();
    const json = await response.json();

    expect(response.status).toEqual(200);
    expect(json.session).toEqual({
      avatarUrl: "",
      login: expect.stringMatching(/^testing-\d+$/),
      name: expect.stringMatching(/^testing user \d+$/),
      source: "google",
      banned: false,
    });
  });
});
