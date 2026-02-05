import { requireSession } from "../../composable/session/middleware";
import { factory } from "../factory";
import get from "./get";
import insertApp from "./insert";
import archiveApp from "./archive";
import editApp from "./edit";
import bulkApp from "./bulk";

export default factory
  .createApp()
  .use(requireSession({ action: "redirect", destination: "/basic" }))
  .get("/", ...get)
  .route("/insert", insertApp)
  .route("/archive", archiveApp)
  .route("/edit", editApp)
  .route("/bulk", bulkApp);
