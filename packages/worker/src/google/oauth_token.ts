import { GoogleTokenExchangeError } from "../error/google";
import type { KyInstance, Options } from "ky";
import * as z from "zod";

export const AccessTokenSchema = z.object({
  access_token: z.string(),
  expires_in: z.number().optional(),
  refresh_token: z.string().optional(),
  scope: z.string(),
  token_type: z.string(),
});

const AccessTokenSchemaWithError = z.union([
  z.object({
    error: z.string(),
    error_description: z.string().optional(),
  }),
  AccessTokenSchema,
]);

/**
 * Exchange authorization access code with Google access token, or refresh token.
 *
 * For login, this calls the token endpoint with authorization_code grant.
 * For refresh, this calls the token endpoint with refresh_token grant.
 *
 * @see https://developers.google.com/identity/protocols/oauth2/web-server#exchange-authorization-code
 * @throws {GoogleTokenExchangeError} access token exchange failed.
 */
export async function exchangeToken(
  env: CloudflareBindings,
  ky: KyInstance,
  code: string,
  codeType: "login" | "refresh",
  redirectUri?: string,
) {
  const options: Options =
    codeType === "login"
      ? {
          json: {
            client_id: env.GOOGLE_CLIENT_ID,
            client_secret: env.GOOGLE_CLIENT_SECRET,
            code,
            redirect_uri: redirectUri,
            grant_type: "authorization_code",
          },
        }
      : {
          json: {
            client_id: env.GOOGLE_CLIENT_ID,
            client_secret: env.GOOGLE_CLIENT_SECRET,
            refresh_token: code,
            grant_type: "refresh_token",
          },
        };

  const accessTokenResp = await ky
    .post("https://oauth2.googleapis.com/token", options)
    .json();

  const parsed = AccessTokenSchemaWithError.parse(accessTokenResp);

  if ("error" in parsed) {
    throw new GoogleTokenExchangeError(
      parsed.error,
      parsed.error_description ?? "",
    );
  }

  return parsed;
}
