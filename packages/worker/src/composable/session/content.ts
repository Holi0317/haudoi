import type { KyInstance } from "ky";
import dayjs from "dayjs";
import { getUser as getGhUser } from "../../gh/user";
import { getUser as getGoogleUser } from "../../google/user";
import type { UserWriteInput } from "../user/registry";
import type { Session } from "./schema";

type Provider = "github" | "google";

interface TokenResult {
  access_token: string;
  refresh_token: string;
  expires_in?: number;
}

/**
 * Exchange access token info to session and user content.
 */
export async function makeSessionContent(
  ky: KyInstance,
  tokens: TokenResult,
  source: Provider,
) {
  const now = dayjs();

  if (source === "github") {
    const userInfo = await getGhUser(ky, tokens.access_token);

    const session: Session = {
      source: "github",
      uid: userInfo.id.toString(),
      accessToken: tokens.access_token,

      // Refresh after 8 hours, even if the GitHub app turned off token expiration.
      accessTokenExpire: now.add(8, "hour").valueOf(),
      refreshToken: tokens.refresh_token,
    };

    const user: UserWriteInput = {
      source: "github",
      uid: userInfo.id.toString(),
      name: userInfo.name || userInfo.login,
      login: userInfo.login,
      avatarUrl: userInfo.avatar_url,
    };

    return {
      session,
      user,
    };
  }

  const userInfo = await getGoogleUser(ky, tokens.access_token);

  const session: Session = {
    source: "google",
    uid: userInfo.id,
    accessToken: tokens.access_token,
    accessTokenExpire: now.add(tokens.expires_in ?? 3600, "second").valueOf(),
    refreshToken: tokens.refresh_token,
  };

  const user: UserWriteInput = {
    source: "google",
    uid: userInfo.id,
    name: userInfo.name ?? userInfo.email,
    login: userInfo.email,
    avatarUrl: userInfo.picture ?? "",
  };

  return {
    session,
    user,
  };
}
