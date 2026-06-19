import type { KyInstance } from "ky";
import * as z from "zod";

const UserInfoSchema = z.object({
  id: z.string(),
  email: z.string(),
  name: z.string().nullable(),
  picture: z.string().nullable(),
});

/**
 * Get authorized user's information from Google.
 *
 * @see https://developers.google.com/identity/protocols/oauth2/web-server#callinganapi
 */
export async function getUser(ky: KyInstance, access_token: string) {
  const userInfoResp = await ky
    .get("https://www.googleapis.com/oauth2/v2/userinfo", {
      headers: {
        authorization: `Bearer ${access_token}`,
      },
    })
    .json();

  return UserInfoSchema.parse(userInfoResp);
}
