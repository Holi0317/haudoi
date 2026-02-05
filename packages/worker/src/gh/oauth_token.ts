import { GitHubTokenExchangeError } from "../error/github";
import type { KyInstance, Options } from "ky";
import * as z from "zod";

export const AccessTokenSchema = z.object({
  /**
   * The user access token. The token starts with ghu_.
   */
  access_token: z.string(),
  /**
   * The number of seconds until access_token expires.
   * If you disabled expiration of user access tokens, this parameter will be omitted.
   * The value will always be 28800 (8 hours).
   */
  expires_in: z.number().optional(),
  /**
   * The refresh token.
   * If you disabled expiration of user access tokens, this parameter will be omitted.
   * The token starts with ghr_.
   */
  refresh_token: z.string({
    error:
      "Missing refresh_token from GitHub. Make sure your GitHub App has refresh tokens enabled.",
  }),
  /**
   * The number of seconds until refresh_token expires.
   * If you disabled expiration of user access tokens, this parameter will be omitted.
   * The value will always be 15897600 (6 months).
   */
  refresh_token_expires_in: z.number(),
});

const AccessTokenSchemaWithError = z.union([
  // You guessed it, Github is returning error in 200 OK response. ky's `throwHttpErrors`
  // won't catch it.
  z.object({
    error: z.string(),
    error_description: z.string(),
    error_uri: z.string(),
  }),
  AccessTokenSchema,
]);

/**
 * Exchange authorization access code with `ghu` access token, or refresh token.
 *
 * For login, this calls the following API:
 * https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-user-access-token-for-a-github-app
 *
 * For refresh, this calls the following API:
 * https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/refreshing-user-access-tokens
 *
 * @throws {GitHubTokenExchangeError} access token exchange failed. Could be the
 * code got reused.
 */
export async function exchangeToken(
  env: CloudflareBindings,
  ky: KyInstance,
  code: string,
  codeType: "login" | "refresh",
) {
  const options: Options =
    codeType === "login"
      ? {
          json: {
            client_id: env.GH_CLIENT_ID,
            client_secret: env.GH_CLIENT_SECRET,
            code,
          },
        }
      : {
          headers: {
            accept: "application/json",
          },
          searchParams: {
            client_id: env.GH_CLIENT_ID,
            client_secret: env.GH_CLIENT_SECRET,
            grant_type: "refresh_token",
            refresh_token: code,
          },
        };

  const accessTokenResp = await ky
    .post("https://github.com/login/oauth/access_token", options)
    .json();

  const parsed = AccessTokenSchemaWithError.parse(accessTokenResp);

  if ("error" in parsed) {
    throw new GitHubTokenExchangeError(parsed.error, parsed.error_description);
  }

  return parsed;
}
