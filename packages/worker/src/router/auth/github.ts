import * as z from "zod";
import dayjs from "dayjs";
import { zv } from "../../composable/validator";
import { factory } from "../factory";
import {
  RedirectDestinationSchema,
  useOauthState,
} from "../../composable/oauth_state";
import { getAuthorizeUrl } from "../../gh/authorize";
import { useUserRegistry } from "../../composable/user/registry";
import { useKy } from "../../composable/http";
import { exchangeToken } from "../../gh/oauth_token";
import { setSession } from "../../composable/session/cookie";
import { makeSessionContent } from "../../composable/session/content";

export default factory
  .createApp()
  .get(
    "/login",
    zv(
      "query",
      z.object({
        redirect: RedirectDestinationSchema.default("/"),
      }),
    ),
    async (c) => {
      const { redirect } = c.req.valid("query");

      const { store } = useOauthState(c.env);

      // Store redirect destination in KV and get state token
      const state = await store(redirect);
      const authUrl = getAuthorizeUrl(c, state);

      console.log(`Redirecting to login ${authUrl}`);

      return c.redirect(authUrl);
    },
  )
  .get(
    "/callback",
    zv("query", z.object({ code: z.string(), state: z.string() })),
    async (c) => {
      const { code, state } = c.req.valid("query");

      const { getAndDelete } = useOauthState(c.env);
      const { write: writeUser } = useUserRegistry(c.env);

      // Retrieve redirect destination from KV using state
      const stateData = await getAndDelete(state);
      if (stateData == null) {
        return c.text("Invalid or expired state parameter", 400);
      }

      const ky = useKy(c);

      const tokens = await exchangeToken(c.env, ky, code, "login");
      const now = dayjs();
      const expire = now.add(7, "day");

      const { session, user } = await makeSessionContent(ky, tokens);

      const sessID = await setSession(c, session, expire);
      await writeUser(user);

      const redirect =
        stateData.redirect === "haudoi:"
          ? `haudoi://login?token=${sessID}`
          : stateData.redirect;
      return c.redirect(redirect);
    },
  );
