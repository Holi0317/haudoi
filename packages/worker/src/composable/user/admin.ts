import type { Context } from "hono";
import { createMiddleware } from "hono/factory";
import { AdminForbiddenError } from "../../error/auth";
import { getUser } from "./getter";

/**
 * Check if current session is an admin session.
 *
 * If no session or user exist, return false.
 * You probably want to add {@link requireSession} middleware before using this.
 *
 * See also {@link requireAdmin} for middleware version of this.
 */
export async function isAdmin(c: Context<Env>) {
  const user = await getUser(c, false);

  if (user == null) {
    return false;
  }

  // GitHub login is case insensitive
  const { compare } = new Intl.Collator(undefined, { sensitivity: "accent" });

  const admins = c.env.ADMIN_GH_LOGIN.split(";")
    .map((s) => s.trim())
    .filter((s) => s.length > 0);

  for (const str of admins) {
    if (compare(str, user.login) === 0) {
      return true;
    }
  }

  return false;
}

/**
 * Middleware for requiring session to be admin before continue.
 */
export function requireAdmin() {
  return createMiddleware<Env>(async (c, next) => {
    const pass = await isAdmin(c);

    if (!pass) {
      throw new AdminForbiddenError();
    }

    await next();
  });
}
