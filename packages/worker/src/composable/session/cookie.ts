import type dayjs from "dayjs";
import type { Context } from "hono";
import { deleteCookie, setCookie } from "hono/cookie";
import { revokeToken as revokeGhToken } from "../../gh/revoke";
import { revokeToken as revokeGoogleToken } from "../../google/revoke";
import { useKy } from "../http";
import { getRefreshStub } from "../do";
import { COOKIE_NAME, cookieOpt } from "./constants";
import { genSessionID, getSessHash, hashSessionID } from "./id";
import { type SessionInput, useSessionStorage } from "./schema";

/**
 * Store session data to KV.
 *
 * This isn't exported. You should use {@link setSession} instead.
 */
async function storeSession(
  env: CloudflareBindings,
  content: SessionInput,
  expire: dayjs.Dayjs,
) {
  const sessID = genSessionID();
  const sessHash = await hashSessionID(sessID);

  const { write } = useSessionStorage(env);

  await write({
    key: sessHash,
    content,
    expire,
  });

  return sessID;
}

/**
 * For testing use only. See {@link storeSession}.
 */
export const __test__storeSession = storeSession;

/**
 * Set session for current request (both cookie and kv).
 */
export async function setSession(
  c: Context<Env>,
  content: SessionInput,
  expire: dayjs.Dayjs,
) {
  const sessID = await storeSession(c.env, content, expire);

  setCookie(c, COOKIE_NAME, sessID, cookieOpt);

  return sessID;
}

/**
 * Delete cookie and session
 */
export async function deleteSession(c: Context<Env>) {
  const { remove, read } = useSessionStorage(c.env);

  // WARNING: Do **NOT** use `getSession` here. It'll cause recursive call.

  // Delete cookie regardless of whether session exists
  deleteCookie(c, COOKIE_NAME, cookieOpt);

  const sessHash = await getSessHash(c);
  if (sessHash == null) {
    return;
  }

  const sess = await read(sessHash);

  await remove(sessHash);

  if (sess != null) {
    try {
      if (sess.source === "google") {
        await revokeGoogleToken(useKy(c), sess.accessToken);
      } else {
        await revokeGhToken(c, useKy(c), sess.accessToken);
      }
    } catch (err) {
      console.warn("Failed to revoke token on session delete.", err);
    }
  }
}

/**
 * Try to refresh session in the background.
 */
export async function refreshSession(c: Context<Env>) {
  const sessHash = await getSessHash(c);
  if (sessHash == null) {
    return;
  }

  const stub = getRefreshStub(c.env, sessHash);

  // Trigger token refresh in the background. Don't wait for it to finish in request-response cycle.
  c.executionCtx.waitUntil(stub.refresh(sessHash));
}
