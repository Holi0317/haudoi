import type { KyInstance } from "ky";

/**
 * Revoke Google access token.
 *
 * @see https://developers.google.com/identity/protocols/oauth2/web-server#tokenrevoke
 */
export async function revokeToken(ky: KyInstance, token: string) {
  await ky.post("https://oauth2.googleapis.com/revoke", {
    searchParams: {
      token,
    },
  });
}
