import { factory } from "../factory";
import logoutApp from "./logout";
import githubApp from "./github";

export default factory
  .createApp()
  .route("/logout", logoutApp)
  .route("/github", githubApp);
