import * as z from "zod";
import * as zu from "../../zod-utils";

export const UserSchema = z.object({
  source: z.enum(["github", "google"]),
  uid: z.string(),

  /**
   * User's display name.
   */
  name: z.string(),

  /**
   * User's login name on GitHub. aka your GitHub username.
   */
  login: z.string(),

  /**
   * User's avatar URL.
   *
   * This is always non-empty because github generates a default avatar if user has not set one.
   */
  avatarUrl: z.string(),

  /**
   * Timestamp for user creation.
   */
  createdAt: zu.unixEpochMs(),

  /**
   * Timestamp for last login.
   *
   * Technically this is updated whenever user data is written,
   * not only on login. Which includes token exchange.
   */
  lastLoginAt: zu.unixEpochMs(),

  /**
   * Timestamp when the user was banned. If null, user is not banned.
   */
  bannedAt: zu.unixEpochMs().nullable().default(null),
});

export const UserMetadataSchema = z.object({
  string: z.string(),
});

export type User = z.output<typeof UserSchema>;
