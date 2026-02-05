import * as z from "zod";
import { zv } from "../../composable/validator";
import { factory } from "../factory";

const ArchiveFormSchema = z.object({
  id: z.coerce.number(),
  qs: z.string().default("?"),
});

export default factory
  .createApp()
  .post("/", zv("form", ArchiveFormSchema), async (c) => {
    const { id, qs } = c.req.valid("form");

    await c.get("client").edit.$post({
      json: {
        op: [{ op: "set_bool", field: "archive", id, value: true }],
      },
    });

    return c.redirect(`/basic${qs}`);
  });
