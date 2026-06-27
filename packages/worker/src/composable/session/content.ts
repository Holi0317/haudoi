import type { KyInstance } from "ky";
import dayjs from "dayjs";
import { getUser as getGoogleUser } from "../../google/user";
import type { UserWriteInput } from "../user/registry";
import type { Session } from "./schema";

interface TokenResult {
  access_token: string;
  refresh_token?: string;
  expires_in?: number;
}

/**
 * Exchange access token info to session and user content.
 *
 * @param fallbackRefreshToken Optional existing refresh token to use when
 *   tokens.refresh_token is undefined (e.g. after a refresh grant).
 */
export async function makeSessionContent(
  ky: KyInstance,
  tokens: TokenResult,
  fallbackRefreshToken?: string,
) {
  const now = dayjs();

  const userInfo = await getGoogleUser(ky, tokens.access_token);

  const session: Session = {
    source: "google",
    uid: userInfo.id,
    accessToken: tokens.access_token,
    accessTokenExpire: now.add(tokens.expires_in ?? 3600, "second").valueOf(),
    refreshToken: tokens.refresh_token ?? fallbackRefreshToken ?? "",
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
