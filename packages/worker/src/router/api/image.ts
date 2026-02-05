import { useCache } from "../../composable/cache";
import { useKy } from "../../composable/http";
import { fetchImage, parseAcceptImageFormat } from "../../composable/image";
import { getFaviconUrl, getSocialImageUrl } from "../../composable/scraper";
import { zv } from "../../composable/validator";
import { ImageQuerySchema } from "../../schemas";
import { factory } from "../factory";

export default factory
  .createApp()
  .get("/", zv("query", ImageQuerySchema), async (c) => {
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
  });
