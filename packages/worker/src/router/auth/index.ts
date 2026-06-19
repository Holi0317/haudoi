import { factory } from "../factory";
import logoutApp from "./logout";
import githubApp from "./github";
import googleApp from "./google";

export default factory
  .createApp()
  .route("/logout", logoutApp)
  .route("/github", githubApp)
  .route("/google", googleApp);
