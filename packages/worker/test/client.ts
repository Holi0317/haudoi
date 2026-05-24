import { env, exports } from "cloudflare:workers";
import dayjs from "dayjs";
import { expect } from "vitest";
import { __test__storeSession } from "../src/composable/session/cookie";
import { COOKIE_NAME } from "../src/composable/session/constants";
import { useUserRegistry } from "../src/composable/user/registry";
import { createClient } from "../src/client";

let nextUserId = 0;
const userIdByScope = new Map<string, string>();

function getTestScope() {
  const state = expect.getState();
  return `${state.testPath ?? "unknown"}:${state.currentTestName ?? "unknown"}`;
}

function getScopedUserId() {
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
    source: "github",
    uid,
    name,
    login,
    avatarUrl: "",
  });

  const sessID = await __test__storeSession(
    env,
    {
      source: "github",
      uid,
      accessToken: "gho_test_token",
      accessTokenExpire: expire.valueOf(),
      refreshToken: "ghr_test_token",
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
