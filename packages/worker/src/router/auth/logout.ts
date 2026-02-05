import { deleteSession } from "../../composable/session/cookie";
import { factory } from "../factory";

export default factory.createApp().get("/", async (c) => {
  await deleteSession(c);
  return c.text("You have been successfully logged out!");
});
