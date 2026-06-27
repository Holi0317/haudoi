import type { Context } from "hono";

/**
 * Get authorization url (login URL) for Google OAuth.
 *
 * @see https://developers.google.com/identity/protocols/oauth2/web-server#creatingclient
 */
export function getAuthorizeUrl(c: Context<Env>, state: string) {
  const redirectUri = new URL(c.req.url);
  redirectUri.hash = "";
  redirectUri.pathname = "/auth/google/callback";
  redirectUri.search = "";
  redirectUri.password = "";

  const param = new URLSearchParams([
    ["client_id", c.env.GOOGLE_CLIENT_ID],
    ["redirect_uri", redirectUri.toString()],
    ["response_type", "code"],
    ["scope", "openid email profile"],
    ["access_type", "offline"],
    ["prompt", "consent"],
    ["state", state],
  ]);

  return `https://accounts.google.com/o/oauth2/v2/auth?${param.toString()}`;
}
