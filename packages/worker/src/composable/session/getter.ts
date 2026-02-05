import type { Context } from "hono";
import { UnauthenticatedError } from "../../error/auth";
import { useReqCache } from "../cache";
import { deleteSession } from "./cookie";
import { getSessHash } from "./id";
import { type Session, useSessionStorage } from "./schema";

/**
 * Get session from request.
 *
 * This function is cached per-request. It's cheap to call it multiple times.
 *
 * `must` is true or omitted in this overload. This will throw 401 error if session is missing.
 * Routers should add `requireSession` middleware in the chain to ensure session exists.
 *
 * @see {requireSession} Middleware for requiring session
 */
export function getSession(c: Context<Env>, must?: true): Promise<Session>;

/**
 * See other overload for documentation. {@link getSession}
 *
 * `must` is false in this overload. This will return null instead of raising error if session is not found.
 */
export function getSession(
  c: Context<Env>,
  must: false,
): Promise<Session | null>;

/**
 * Get session from request.
 *
 * When this returns some value, the session has been validated.
 *
 * This function is cached/memorized.
 *
 * @see {requireSession} Middleware for requiring session
 */
export async function getSession(c: Context<Env>, must: boolean = true) {
  const session = await useReqCache(c, "session", async () => {
    const { read } = useSessionStorage(c.env);

    const sessHash = await getSessHash(c);
    // Cookie doesn't exist. User is unauthenticated.
    if (!sessHash) {
      await deleteSession(c);
      return null;
    }

    const sess = await read(sessHash);

    // Session does not exist, or expired
    if (sess == null) {
      await deleteSession(c);
      return null;
    }

    return sess;
  });

  if (must && session == null) {
    console.warn(
      "Got null session when must=true. Did the route forget `requireSession` middleware?",
    );

    throw new UnauthenticatedError();
  }

  return session;
}
