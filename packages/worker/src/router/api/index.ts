import { requireSession } from "../../composable/session/middleware";
import { factory } from "../factory";
import version from "./version";
import imageApp from "./image";
import itemApp from "./item";
import searchApp from "./search";
import editApp from "./edit";
import bulkApp from "./bulk";

const app = factory
  .createApp()
  .get("/", ...version)
  .use(requireSession({ action: "throw" }))
  .route("/image", imageApp)
  .route("/item", itemApp)
  .route("/search", searchApp)
  .route("/edit", editApp)
  .route("/bulk", bulkApp);

export default app;

export type APIAppType = typeof app;
