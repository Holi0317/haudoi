import { factory } from "./factory";
import { bodyLimit } from "hono/body-limit";
import { clientInject } from "../middleware/client";
import { renderer } from "../middleware/renderer";
import { blockRequestLoop } from "../middleware/loop";
import apiRouter from "./api";
import authRouter from "./auth";
import basicRouter from "./basic";
import landingRouter from "./landing";
import adminRouter from "./admin";
import { MAX_BODY_SIZE } from "../constants";

const app = factory
  .createApp()
  .use(clientInject(apiRouter))
  .use(renderer())
  .use(blockRequestLoop())
  .use(bodyLimit({ maxSize: MAX_BODY_SIZE }))
  .route("/", landingRouter)
  .route("/auth", authRouter)
  .route("/api", apiRouter)
  .route("/basic", basicRouter)
  .route("/admin", adminRouter);

export default app;

export type AppType = typeof app;
