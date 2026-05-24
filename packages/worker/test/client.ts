import { env, exports } from "cloudflare:workers";
import dayjs from "dayjs";
import { __test__storeSession } from "../src/composable/session/cookie";
import { COOKIE_NAME } from "../src/composable/session/constants";
import { useUserRegistry } from "../src/composable/user/registry";
import { createClient } from "../src/client";

export async function createTestClient() {
  const { write: writeUser } = useUserRegistry(env);

  const expire = dayjs().add(1, "day");

  await writeUser({
    source: "github",
    uid: "1",
    name: "testing user",
    login: "testing",
    avatarUrl: "",
  });

  const sessID = await __test__storeSession(
    env,
    {
      source: "github",
      uid: "1",
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
