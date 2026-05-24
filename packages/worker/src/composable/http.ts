import type { Context } from "hono";
import ky from "ky";

/**
 * Create a ky instance for the given hono context.
 */
export function useKy(c: Context<Env>) {
  return ky.create({
    prefix: "",
    signal: c.req.raw.signal,
    headers: {
      "user-agent": `haudoi-worker/${c.env.CF_VERSION_METADATA.id || "unknown"}/${c.env.CF_VERSION_METADATA.tag || "unknown"}`,
    },
  });
}

/**
 * Create a ky instance when no hono context is available.
 */
export function useBasicKy(env: CloudflareBindings) {
  const version = env.CF_VERSION_METADATA;

  return ky.create({
    prefix: "",
    headers: {
      "user-agent": `haudoi-worker/${version.id || "unknown"}/${version.tag || "unknown"}`,
    },
  });
}
