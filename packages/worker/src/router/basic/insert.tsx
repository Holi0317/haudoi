import * as z from "zod";
import * as zu from "../../zod-utils";
import { zv } from "../../composable/validator";
import { factory } from "../factory";

const InsertFormSchema = z.object({
  url: z.string(),
  qs: zu.queryString(),
});

export default factory
  .createApp()
  .post("/", zv("form", InsertFormSchema), async (c) => {
    const { url, qs } = c.req.valid("form");

    const resp = await c.get("client").edit.$post({
      json: {
        op: [{ op: "insert", url }],
      },
    });

    if (resp.status >= 400) {
      return c.json(await resp.json(), resp.status);
    }

    return c.redirect(`/basic${qs}`);
  });
