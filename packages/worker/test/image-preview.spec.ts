import { describe, it, expect, beforeAll, afterEach } from "vitest";
import { fetchMock } from "./fetch-mock";
import { createTestClient } from "./client";

function makeTestUrl(path: string) {
  const name = expect.getState().currentTestName ?? "unknown";
  const query = new URLSearchParams({ test: name }).toString();
  return `https://example.com${path}?${query}`;
}

describe("Image preview API", () => {
  beforeAll(() => {
    fetchMock.activate();
    fetchMock.disableNetConnect();
  });

  afterEach(() => fetchMock.assertNoPendingInterceptors());

  describe("Social Image", () => {
    it("should return image when og:image meta tag is present", async () => {
      const client = await createTestClient();

      // Mock the HTML page with og:image
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
        <html>
          <head>
            <meta property="og:image" content="https://example.com/image.jpg" />
          </head>
        </html>`,
        );

      // Mock the image fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/image.jpg", method: "get" })
        .reply(200, "fake-image-data", {
          headers: { "Content-Type": "image/jpeg" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page") },
      });

      expect(resp.status).toEqual(200);
      expect(resp.headers.get("Content-Type")).toEqual("image/jpeg");
      expect(await resp.text()).toEqual("fake-image-data");
    });

    it("should return image when twitter:image meta tag is present", async () => {
      const client = await createTestClient();

      // Mock the HTML page with twitter:image
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
        <html>
          <head>
            <meta name="twitter:image" content="https://example.com/twitter-image.png" />
          </head>
        </html>`,
        );

      // Mock the image fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/twitter-image.png", method: "get" })
        .reply(200, "fake-twitter-image", {
          headers: { "Content-Type": "image/png" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page") },
      });

      expect(resp.status).toEqual(200);
      expect(resp.headers.get("Content-Type")).toEqual("image/png");
      expect(await resp.text()).toEqual("fake-twitter-image");
    });

    it("should prefer the last image tag", async () => {
      const client = await createTestClient();

      // Mock the HTML page with both meta tags
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
        <html>
          <head>
            <meta property="og:image" content="https://example.com/og-image.jpg" />
            <meta name="twitter:image" content="https://example.com/twitter-image.png" />
          </head>
        </html>`,
        );

      // Mock the image fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/twitter-image.png", method: "get" })
        .reply(200, "twitter-image-data", {
          headers: { "Content-Type": "image/png" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page") },
      });

      expect(resp.status).toEqual(200);
      expect(resp.headers.get("Content-Type")).toEqual("image/png");
      expect(await resp.text()).toEqual("twitter-image-data");
    });

    it("should return 404 when no image meta tags are present", async () => {
      const client = await createTestClient();

      // Mock the HTML page without image meta tags
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/no-image", method: "get" })
        .reply(
          200,
          `<!doctype html>
        <html>
          <head>
            <title>Page without image</title>
          </head>
        </html>`,
        );

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/no-image") },
      });

      expect(resp.status).toEqual(404);
      expect(await resp.text()).toEqual("");
    });

    it("should return 404 when the page cannot be fetched", async () => {
      const client = await createTestClient();

      fetchMock
        .get("https://example.com")
        .intercept({ path: "/nonexistent", method: "get" })
        .reply(500, "boom");

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/nonexistent") },
      });

      expect(resp.status).toEqual(404);
      expect(await resp.text()).toEqual("");
    });

    async function testReturn404() {
      const client = await createTestClient();

      // Mock the HTML page with og:image
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
        <html>
          <head>
            <meta property="og:image" content="https://example.com/broken-image.jpg" />
          </head>
        </html>`,
        );

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page") },
      });

      expect(resp.status).toEqual(404);
      expect(await resp.text()).toEqual("");
    }

    it("should return 404 when the image URL returns 500", async () => {
      // Image fetch fails
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/broken-image.jpg", method: "get" })
        .reply(500, "xxx", {
          headers: { "Content-Type": "image/png" },
        });

      await testReturn404();
    });

    it("should return 404 when the image URL returns non image/* content-type", async () => {
      // Image fetch fails
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/broken-image.jpg", method: "get" })
        .reply(200, "xxx", {
          headers: { "Content-Type": "application/zip" },
        });

      await testReturn404();
    });
  });

  describe("Favicon type", () => {
    it("should return favicon when type=favicon and link rel=icon is present", async () => {
      const client = await createTestClient();

      // Mock the HTML page with favicon link
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="icon" href="/custom-favicon.ico" />
            </head>
          </html>`,
        );

      // Mock the favicon fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/custom-favicon.ico", method: "get" })
        .reply(200, "favicon-data", {
          headers: { "Content-Type": "image/x-icon" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(resp.headers.get("Content-Type")).toEqual("image/x-icon");
      expect(await resp.text()).toEqual("favicon-data");
    });

    it("should fallback to /favicon.ico when no favicon link tag is present", async () => {
      const client = await createTestClient();

      // Mock the HTML page without favicon link
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <title>Page without favicon link</title>
            </head>
          </html>`,
        );

      // Mock the fallback favicon fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/favicon.ico", method: "get" })
        .reply(200, "default-favicon", {
          headers: { "Content-Type": "image/x-icon" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(resp.headers.get("Content-Type")).toEqual("image/x-icon");
      expect(await resp.text()).toEqual("default-favicon");
    });

    it("should handle shortcut icon rel attribute", async () => {
      const client = await createTestClient();

      // Mock the HTML page with shortcut icon
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="shortcut icon" href="/shortcut.ico" />
            </head>
          </html>`,
        );

      // Mock the favicon fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/shortcut.ico", method: "get" })
        .reply(200, "shortcut-favicon", {
          headers: { "Content-Type": "image/x-icon" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(await resp.text()).toEqual("shortcut-favicon");
    });

    it("should default to social type when type is not specified", async () => {
      const client = await createTestClient();

      // Mock the HTML page with both favicon and og:image
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="icon" href="/favicon.ico" />
              <meta property="og:image" content="https://example.com/social.jpg" />
            </head>
          </html>`,
        );

      // Mock the social image fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/social.jpg", method: "get" })
        .reply(200, "social-image", {
          headers: { "Content-Type": "image/jpeg" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page") },
      });

      expect(resp.status).toEqual(200);
      expect(await resp.text()).toEqual("social-image");
    });

    it("should reject favicon with type=image/svg+xml", async () => {
      const client = await createTestClient();

      // Mock the HTML page with SVG icon (should be rejected) and fallback to default
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="icon" type="image/svg+xml" href="/icon.svg" />
            </head>
          </html>`,
        );

      // Mock the fallback favicon fetch (since SVG is rejected)
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/favicon.ico", method: "get" })
        .reply(200, "default-favicon", {
          headers: { "Content-Type": "image/x-icon" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(await resp.text()).toEqual("default-favicon");
    });

    it("should prioritize icon over shortcut icon when both present", async () => {
      const client = await createTestClient();

      // Mock the HTML page with multiple favicon types
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="shortcut icon" href="/shortcut.ico" />
              <link rel="icon" href="/icon.ico" />
            </head>
          </html>`,
        );

      // Mock the icon.ico fetch (should be used due to higher priority)
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/icon.ico", method: "get" })
        .reply(200, "icon-favicon", {
          headers: { "Content-Type": "image/x-icon" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(await resp.text()).toEqual("icon-favicon");
    });

    it("should select last element when multiple elements with same rel present", async () => {
      const client = await createTestClient();

      // Mock the HTML page with multiple icon rel elements (last should be used)
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="icon" href="/first-icon.ico" />
              <link rel="icon" href="/second-icon.ico" />
              <link rel="icon" href="/last-icon.ico" />
            </head>
          </html>`,
        );

      // Mock the last-icon.ico fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/last-icon.ico", method: "get" })
        .reply(200, "last-icon-data", {
          headers: { "Content-Type": "image/x-icon" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(await resp.text()).toEqual("last-icon-data");
    });

    it("should prioritize icon over apple-touch-icon", async () => {
      const client = await createTestClient();

      // Mock the HTML page with apple-touch-icon and icon
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="apple-touch-icon" href="/apple-icon.png" />
              <link rel="icon" href="/icon.ico" />
            </head>
          </html>`,
        );

      // Mock the icon.ico fetch (should be used due to higher priority)
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/icon.ico", method: "get" })
        .reply(200, "icon-favicon", {
          headers: { "Content-Type": "image/x-icon" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(await resp.text()).toEqual("icon-favicon");
    });

    it("should use apple-touch-icon when icon and shortcut icon not present", async () => {
      const client = await createTestClient();

      // Mock the HTML page with only apple-touch-icon
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="apple-touch-icon" href="/apple-icon.png" />
            </head>
          </html>`,
        );

      // Mock the apple-icon.png fetch
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/apple-icon.png", method: "get" })
        .reply(200, "apple-icon-data", {
          headers: { "Content-Type": "image/png" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(await resp.text()).toEqual("apple-icon-data");
    });

    it("should handle mixed SVG and non-SVG icons, using non-SVG with highest priority", async () => {
      const client = await createTestClient();

      // Mock the HTML page with SVG icon followed by PNG icon
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/page", method: "get" })
        .reply(
          200,
          `<!doctype html>
          <html>
            <head>
              <link rel="icon" type="image/svg+xml" href="/icon.svg" />
              <link rel="icon" href="/icon.png" />
            </head>
          </html>`,
        );

      // Mock the icon.png fetch (SVG is rejected, PNG is used)
      fetchMock
        .get("https://example.com")
        .intercept({ path: "/icon.png", method: "get" })
        .reply(200, "icon-png-data", {
          headers: { "Content-Type": "image/png" },
        });

      const resp = await client.api.image.$get({
        query: { url: makeTestUrl("/page"), type: "favicon" },
      });

      expect(resp.status).toEqual(200);
      expect(await resp.text()).toEqual("icon-png-data");
    });
  });
});
