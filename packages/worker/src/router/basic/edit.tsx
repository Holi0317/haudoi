import * as z from "zod";
import * as zu from "../../zod-utils";
import { zv } from "../../composable/validator";
import { factory } from "../factory";
import { IDStringSchema, type EditOpSchema } from "../../schemas";
import { Layout } from "../../component/layout";
import { LinkItemForm } from "../../component/LinkItemForm";

const ItemEditSchema = z.object({
  archive: zu.checkboxBool(),
  favorite: zu.checkboxBool(),
  note: z.string().max(4096).optional(),
});

export default factory
  .createApp()
  .get("/:id", zv("param", IDStringSchema), async (c) => {
    const { id } = c.req.valid("param");

    const resp = await c.get("client").item[":id"].$get({
      param: {
        id: id.toString(),
      },
    });

    if (resp.status === 404) {
      return c.text("not found", 404);
    }

    const jason = await resp.json();

    return c.render(
      <Layout title="Edit">
        <a href="/basic">Back</a>
        <LinkItemForm item={jason} />

        <form method="post" action={`/basic/edit/${id}/delete`}>
          <input type="submit" value="Delete" />
        </form>
      </Layout>,
    );
  })
  .post(
    "/:id",
    zv("param", IDStringSchema),
    zv("form", ItemEditSchema),
    async (c) => {
      const { id } = c.req.valid("param");
      const form = c.req.valid("form");

      const op: Array<z.input<typeof EditOpSchema>> = [];

      if (form.archive != null) {
        op.push({
          op: "set_bool",
          field: "archive",
          id,
          value: form.archive,
        });
      }

      if (form.favorite != null) {
        op.push({
          op: "set_bool",
          field: "favorite",
          id,
          value: form.favorite,
        });
      }

      if (form.note != null) {
        op.push({
          op: "set_string",
          field: "note",
          id,
          value: form.note,
        });
      }

      await c.get("client").edit.$post({
        json: {
          op,
        },
      });

      return c.redirect(`/basic/edit/${id}`);
    },
  )
  .post("/:id/delete", zv("param", IDStringSchema), async (c) => {
    const { id } = c.req.valid("param");

    await c.get("client").edit.$post({
      json: {
        op: [{ op: "delete", id }],
      },
    });

    return c.redirect(`/basic`);
  });
