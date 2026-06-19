import { env, exports } from "cloudflare:workers";
import dayjs from "dayjs";
import { expect } from "vitest";
import { __test__storeSession } from "../src/composable/session/cookie";
import { COOKIE_NAME } from "../src/composable/session/constants";
import { useUserRegistry } from "../src/composable/user/registry";
import { createClient } from "../src/client";

let nextUserId = 0;
// Vitest pool storage is isolated per file, not per test. Keep a stable
// user identity per test case so multiple createTestClient() calls in one
// test share the same user/DO state, while different tests stay isolated.
const userIdByScope = new Map<string, string>();

function getTestScope() {
  const state = expect.getState();
  return `${state.testPath ?? "unknown"}:${state.currentTestName ?? "unknown"}`;
}

function getScopedUserId() {
  // Scope key is "file + test name".
  const scope = getTestScope();
  const existing = userIdByScope.get(scope);

  if (existing != null) {
    return existing;
  }

  const uid = `${++nextUserId}`;
  userIdByScope.set(scope, uid);
  return uid;
}

export async function createTestClient() {
  const uid = getScopedUserId();
  const login = `testing-${uid}`;
  const name = `testing user ${uid}`;

  const { write: writeUser } = useUserRegistry(env);

  const expire = dayjs().add(1, "day");

  await writeUser({
    source: "google",
    uid,
    name,
    login,
    avatarUrl: "",
  });

  const sessID = await __test__storeSession(
    env,
    {
      source: "google",
      uid,
      accessToken: "google_test_token",
      accessTokenExpire: expire.valueOf(),
      refreshToken: "google_test_refresh_token",
    },
    expire,
  );

  return createClient("http://example.com", {
    fetch: exports.default.fetch.bind(exports.default),
    headers: {
      cookie: `__Host-${COOKIE_NAME}=${sessID}`,
      accept: "application/json",
    },
  });
}
