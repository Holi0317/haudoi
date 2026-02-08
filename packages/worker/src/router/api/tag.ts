import { getStorageStub } from "../../composable/do";
import { zv } from "../../composable/validator";
import {
  IDStringSchema,
  TagCreateSchema,
  TagUpdateSchema,
} from "../../schemas";
import { factory } from "../factory";

export default factory
  .createApp()
  .get("/", async (c) => {
    const stub = await getStorageStub(c);

    const items = await stub.listTags();

    return c.json({ items });
  })
  .post("/", zv("json", TagCreateSchema), async (c) => {
    const stub = await getStorageStub(c);
    const body = c.req.valid("json");

    const result = await stub.createTag(body);

    return c.json(result, 201);
  })
  .patch(
    "/:id",
    zv("param", IDStringSchema),
    zv("json", TagUpdateSchema),
    async (c) => {
      const stub = await getStorageStub(c);
      const { id } = c.req.valid("param");
      const body = c.req.valid("json");

      const result = await stub.updateTag(id, body);

      if (result == null) {
        return c.json({ message: "not found" }, 404);
      }

      return c.json(result);
    },
  )
  .delete("/:id", zv("param", IDStringSchema), async (c) => {
    const stub = await getStorageStub(c);
    const { id } = c.req.valid("param");

    await stub.deleteTag(id);

    return c.body(null, 204);
  });
