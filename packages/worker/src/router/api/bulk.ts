import * as z from "zod";
import { getImportStub, getStorageStub } from "../../composable/do";
import { zv } from "../../composable/validator";
import { factory } from "../factory";
import { useImportStore, type CsvFormat } from "../../composable/import";
import { getUser } from "../../composable/user/getter";

export default factory
  .createApp()
  .post("/export", async (c) => {
    const stub = await getStorageStub(c);

    const csv = await stub.export_();

    return new Response(csv, {
      status: 200,
      headers: {
        "content-type": "text/csv; charset=utf-8",
        "content-disposition": 'attachment; filename="haudoi_export.csv"',
      },
    });
  })
  .get("/import", async (c) => {
    const stub = await getImportStub(c);
    const status = await stub.status();

    return c.json({ status });
  })
  .post(
    "/import",
    zv(
      "form",
      z.object({
        // `z.file()` is broken. zod relies on globalThis.File which isn't available or inferrable
        // in this typescript environment.
        // Using instanceof check as a workaround.
        file: z.instanceof(File),
        format: z
          .enum(["pocket", "raindrop"])
          .default("pocket") satisfies z.ZodType<CsvFormat>,
      }),
    ),
    async (c) => {
      const { writeRaw } = useImportStore(c.env);
      const stub = await getImportStub(c);
      const user = await getUser(c);
      const { file, format } = c.req.valid("form");

      const content = await file.text();

      const rawId = await writeRaw(user, content, format);
      console.log("Wrote import raw data with ID:", rawId);

      const status = await stub.start(user, rawId, format);
      console.log("Started import with status:", status);

      return c.json({ status }, 201);
    },
  );
