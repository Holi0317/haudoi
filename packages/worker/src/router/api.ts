import { factory } from "./factory";
import * as z from "zod";
import { zv } from "../composable/validator";
import { getImportStub, getStorageStub } from "../composable/do";
import { requireSession } from "../composable/session/middleware";
import { getSocialImageUrl, getFaviconUrl } from "../composable/scraper";
import { useKy } from "../composable/http";
import { encodeCursor } from "../composable/cursor";
import {
  EditBodySchema,
  IDStringSchema,
  SearchQuerySchema,
  ImageQuerySchema,
} from "../schemas";
import { fetchImage, parseAcceptImageFormat } from "../composable/image";
import { useCache } from "../composable/cache";
import { getUser } from "../composable/user/getter";
import { processInsert } from "../composable/insert";
import { useImportStore } from "../composable/import";
import { parseDSL, type FieldConfig } from "@haudoi/dsl";
import { HTTPException } from "hono/http-exception";

/**
 * Field configuration for DSL search
 */
const SEARCH_FIELDS: FieldConfig[] = [
  { name: "archive", type: "boolean", column: "archive" },
  { name: "favorite", type: "boolean", column: "favorite" },
  { name: "url", type: "string", column: "url" },
  { name: "title", type: "string", column: "title" },
  { name: "note", type: "string", column: "note" },
];

const app = factory
  .createApp()
  /**
   * Version check / user info endpoint
   */
  .get("/", async (c) => {
    const user = await getUser(c, false);

    return c.json({
      // This name is used for client to probe and verify the correct API endpoint.
      name: "haudoi",
      version: c.env.CF_VERSION_METADATA,
      session:
        user == null
          ? null
          : {
              source: user.source,
              name: user.name,
              login: user.login,
              avatarUrl: user.avatarUrl,
              banned: user.bannedAt != null,
            },
    });
  })
  .use(requireSession({ action: "throw" }))

  .get("/image", zv("query", ImageQuerySchema), async (c) => {
    const { url, type, dpr, width, height } = c.req.valid("query");
    const format = parseAcceptImageFormat(c);

    // Create a cache key based on the URL and parameters
    const cacheKey = new URL(url);

    // Override search params for cache key
    // Adding `x-` prefix to avoid (unlikely) collision with original URL params
    const override = {
      "x-type": type,
      "x-dpr": dpr?.toString() || "",
      "x-width": width?.toString() || "",
      "x-height": height?.toString() || "",
      "x-format": format,
    };

    for (const [key, value] of Object.entries(override)) {
      if (value) {
        cacheKey.searchParams.append(key, value);
      }
    }

    const ky = useKy(c);

    // Abuse useCache for caching extracted image URL
    // Use different cache namespace for social vs favicon
    const cacheNamespace = type === "favicon" ? "favicon_url" : "image_url";
    const imageUrlResp = await useCache(
      cacheNamespace,
      new URL(url),
      async () => {
        // Fetch and extract image URL from the page based on type
        let imageUrl: URL | null = null;

        if (type === "favicon") {
          imageUrl = await getFaviconUrl(ky, url);
        } else {
          imageUrl = await getSocialImageUrl(ky, url);
        }

        const body = imageUrl == null ? "" : imageUrl.toString();

        return new Response(body, {
          status: 200,
          headers: {
            "content-type": "text/plain",
            // Cache for 24 hours. Maybe I should respect Cache-Control from origin instead?
            "cache-control": "public, max-age=86400",
          },
        });
      },
    );

    const imageUrl = await imageUrlResp.text();
    if (imageUrl === "") {
      console.info(`No ${type} image found for URL`, url);
      return c.text("", 404);
    }

    return await fetchImage(ky, new URL(imageUrl), {
      dpr,
      width,
      height,
      format,
    });
  })

  .get("/item/:id", zv("param", IDStringSchema), async (c) => {
    const stub = await getStorageStub(c);
    const { id } = c.req.valid("param");

    const item = await stub.get(id);

    if (item == null) {
      return c.json(
        {
          message: "not found",
        },
        404,
      );
    }

    return c.json(item);
  })

  .get("/search", zv("query", SearchQuerySchema), async (c) => {
    const stub = await getStorageStub(c);

    const q = c.req.valid("query");

    // Parse DSL query string
    let matchers;
    try {
      const parseResult = parseDSL(q.query, SEARCH_FIELDS);

      // Check for parsing errors (e.g., unknown field)
      if (parseResult.errors.length > 0) {
        throw new HTTPException(400, {
          message: `Invalid search query: ${parseResult.errors.join("; ")}`,
        });
      }

      matchers = parseResult.matchers;
    } catch (error) {
      throw new HTTPException(400, {
        message:
          error instanceof Error ? error.message : "Invalid search query",
        cause: error,
      });
    }

    const search = await stub.search(
      { limit: q.limit, order: q.order, cursor: q.cursor },
      matchers,
    );

    const lastItem = search.items.at(-1);
    const cursor =
      lastItem == null || !search.hasMore ? null : encodeCursor(lastItem);

    return c.json({
      ...search,
      cursor,
    });
  })

  .post("/edit", zv("json", EditBodySchema), async (c) => {
    const body = c.req.valid("json");

    const stub = await getStorageStub(c);
    const ky = useKy(c);

    const edits = body.op.filter((op) => op.op !== "insert");
    const inserts = await processInsert(
      ky,
      body.op.filter((op) => op.op === "insert"),
    );

    // Apply edits before inserts. We don't want to allow user to edit newly inserted
    // items by predicting their IDs.
    if (edits.length) {
      await stub.edit(edits);
    }

    const insertedIds: number[] = [];
    if (inserts.length) {
      const insertedItems = await stub.insert(inserts);
      insertedIds.push(...insertedItems.map((item) => item.id));
    }

    return c.json(
      {
        // Return inserted IDs for client
        // Actually I am not sure what else the client would need here.
        // Currently the only use case is to allow client to delete newly inserted items right away.
        insert: {
          ids: insertedIds,
        },
      },
      201,
    );
  })
  .post("/bulk/export", async (c) => {
    const stub = await getStorageStub(c);

    const csv = await stub.export_();

    return new Response(csv, {
      status: 200,
      headers: {
        "content-type": "text/csv; charset=utf-8",
        "content-disposition": 'attachment; filename="haudoi_export.csv"',
      },
    });
  })
  .get("/bulk/import", async (c) => {
    const stub = await getImportStub(c);
    const status = await stub.status();

    return c.json({ status });
  })
  .post(
    "/bulk/import",
    zv(
      "form",
      z.object({
        // `z.file()` is broken. zod relies on globalThis.File which isn't available or inferrable
        // in this typescript environment.
        // Using instanceof check as a workaround.
        file: z.instanceof(File),
      }),
    ),
    async (c) => {
      const { writeRaw } = useImportStore(c.env);
      const stub = await getImportStub(c);
      const user = await getUser(c);
      const { file } = c.req.valid("form");

      const content = await file.text();

      const rawId = await writeRaw(user, content);
      console.log("Wrote import raw data with ID:", rawId);

      const status = await stub.start(user, rawId);
      console.log("Started import with status:", status);

      return c.json({ status }, 201);
    },
  );

export default app;

export type APIAppType = typeof app;
