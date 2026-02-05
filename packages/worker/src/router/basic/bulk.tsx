import * as z from "zod";
import { ImportForm } from "../../component/ImportForm";
import { ImportStatus } from "../../component/ImportStatus";
import { Layout } from "../../component/layout";
import { zv } from "../../composable/validator";
import { factory } from "../factory";

export default factory
  .createApp()
  .get("/", async (c) => {
    const { status } = await c
      .get("client")
      .bulk.import.$get()
      .then((r) => r.json());

    return c.render(
      <Layout title="Import / Export">
        <a href="/basic">Back</a>
        <h2>Import</h2>

        <ImportStatus status={status} />
        {(status == null || status.completed != null) && <ImportForm />}

        <h2>Export</h2>
        <form method="post" action="/api/bulk/export">
          <input type="submit" value="Export CSV" />
        </form>
      </Layout>,
    );
  })
  .post(
    "/",
    zv(
      "form",
      z.object({
        // `z.file()` is broken. zod relies on globalThis.File which isn't available or inferrable
        // in this typescript environment.
        // Using instanceof check as a workaround.
        file: z.instanceof(File),
      }),
    ),
    async (c) => {
      const client = c.get("client");
      const { file } = c.req.valid("form");

      const resp = await client.bulk.import.$post({
        form: {
          file,
        },
      });

      if (!resp.ok) {
        return c.json(await resp.json(), resp.status);
      }

      return c.redirect("/basic/bulk");
    },
  );
