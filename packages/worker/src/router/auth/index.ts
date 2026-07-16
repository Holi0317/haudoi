import { factory } from "../factory";
import logoutApp from "./logout";
import googleApp from "./google";

export default factory
  .createApp()
  .route("/logout", logoutApp)
  .route("/google", googleApp);
