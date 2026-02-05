import { getStorageStub } from "../../composable/do";
import { zv } from "../../composable/validator";
import { IDStringSchema } from "../../schemas";
import { factory } from "../factory";

export default factory
  .createApp()
  .get("/:id", zv("param", IDStringSchema), async (c) => {
    const stub = await getStorageStub(c);
    const { id } = c.req.valid("param");

    const item = await stub.get(id);

    if (item == null) {
      return c.json(
        {
          message: "not found",
        },
        404,
      );
    }

    return c.json(item);
  });
