import { createMiddleware } from "hono/factory";
import {
  InternalServerError,
  UnauthenticatedError,
  UserBannedError,
} from "../../error/auth";
import { every } from "hono/combine";
import type { RedirectDestination } from "../oauth_state";
import { isAdmin } from "../user/admin";
import { getUser } from "../user/getter";
import { refreshSession } from "./cookie";
import { getSession } from "./getter";

export type RequireSessionOption =
  | {
      /**
       * If user is not authenticated, throw HTTP 401 error.
       */
      action: "throw";
    }
  | {
      /**
       * If user is not authenticated, redirect to `destination` property
       */
      action: "redirect";
      /**
       * Redirect destination URL after authentication.
       */
      destination: RedirectDestination;
    };

function _requireSession(option: RequireSessionOption) {
  return createMiddleware<Env>(async (c, next) => {
    const sess = await getSession(c, false);
    if (sess != null) {
      await next();
      return;
    }

    if (option.action === "throw") {
      throw new UnauthenticatedError();
    }

    return c.redirect(`/auth/github/login?redirect=${option.destination}`);
  });
}

function _requireUser() {
  return createMiddleware<Env>(async (c, next) => {
    const user = await getUser(c, false);

    if (user != null) {
      await next();
      return;
    }

    console.error(
      "User not found in requireUser middleware despite having a valid session",
    );

    throw new InternalServerError();
  });
}

/**
 * Refresh session in the background, if needed.
 */
function _refreshMiddleware() {
  return createMiddleware<Env>(async (c, next) => {
    await refreshSession(c);

    await next();
  });
}

/**
 * Middleware for requiring user is not banned.
 */
function _requireUnbanned() {
  return createMiddleware<Env>(async (c, next) => {
    const user = await getUser(c);

    if (user.bannedAt == null) {
      await next();
      return;
    }

    // User is banned here.

    // Allow admin users to proceed
    const admin = await isAdmin(c);
    if (admin) {
      console.warn(`Admin user ${user.login} is banned but allowed to proceed`);
      await next();
      return;
    }

    throw new UserBannedError(user.bannedAt);
  });
}

/**
 * Middleware for requiring session before continue.
 *
 * This actually combines multiple middlewares:
 * - require session exists in KV
 * - require user exists in KV
 * - require user is not banned
 * - refresh session in the background
 *
 * @param option Handle strategy for missing session.
 * "throw": HTTP response with error 401 status
 * "redirect": Redirect to login url. After login, user will be redirected back to the original url.
 */
export function requireSession(option: RequireSessionOption) {
  return every(
    _requireSession(option),
    _requireUser(),
    _requireUnbanned(),
    _refreshMiddleware(),
  );
}
