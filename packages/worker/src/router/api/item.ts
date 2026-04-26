import { getStorageStub } from "../../composable/do";
import { ResourceNotFoundError } from "../../error/resource";
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
      throw new ResourceNotFoundError("Link not found", {
        resource: "item",
        id,
      });
    }

    return c.json(item);
  });
