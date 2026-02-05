import { getUser } from "../../composable/user/getter";
import { factory } from "../factory";

/**
 * Version check / user info endpoint
 */
export default factory.createHandlers(async (c) => {
  const user = await getUser(c, false);

  return c.json({
    // This name is used for client to probe and verify the correct API endpoint.
    name: "haudoi",
    version: c.env.CF_VERSION_METADATA,
    session:
      user == null
        ? null
        : {
            source: user.source,
            name: user.name,
            login: user.login,
            avatarUrl: user.avatarUrl,
            banned: user.bannedAt != null,
          },
  });
});
