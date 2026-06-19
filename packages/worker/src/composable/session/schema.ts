import * as z from "zod";
import * as zu from "../../zod-utils";
import { useKv } from "../kv";

/**
 * Schema for session data stored in KV.
 */
export const SessionSchema = z.object({
  /**
   * Source of the user / IdP provider.
   */
  source: z.enum(["github", "google"]),
  uid: z.string(),
  accessToken: z.string(),
  /**
   * Time for access token to expire, in milliseconds since epoch
   */
  accessTokenExpire: zu.unixEpochMs(),
  refreshToken: z.string(),
});

/**
 * Session content type.
 */
export type Session = z.output<typeof SessionSchema>;

/**
 * Input type for session data.
 * Ths should be similar or same as {@link Session}, but technically they are distinct.
 */
export type SessionInput = z.input<typeof SessionSchema>;

export function useSessionStorage(env: CloudflareBindings) {
  return useKv(env.KV, "session", SessionSchema, z.undefined());
}
