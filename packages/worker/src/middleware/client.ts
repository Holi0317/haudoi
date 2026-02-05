import { factory } from "../router/factory";
import { hc } from "hono/client";
import type { APIAppType } from "../router/api";

/**
 * Inject `client` property to the request.
 *
 * That's a mostly functional hc client. Main usecase is to send "request" to
 * api side from html rendering side.
 *
 * Note that we are injecting API client, not the client for whole app.
 */
export function clientInject(app: APIAppType) {
  return factory.createMiddleware(async (c, next) => {
    c.set(
      "client",
      hc<APIAppType>("https://example.com", {
        async fetch(
          input: string | URL | globalThis.Request,
          init?: RequestInit,
        ): Promise<Response> {
          const req = new Request(input, init);

          // Make sure we inherit some headers from the actual request. This way we
          // can have cookies sent to the api properly
          const cookie = c.req.header("cookie");
          if (cookie) {
            req.headers.set("Cookie", cookie);
          }

          const ip = c.req.header("cf-connecting-ip");
          if (ip) {
            req.headers.set("cf-connecting-ip", ip);
          }

          return app.fetch(req, c.env, c.executionCtx);
        },
      }),
    );

    await next();
  });
}
