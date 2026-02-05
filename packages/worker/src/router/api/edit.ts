import { getStorageStub } from "../../composable/do";
import { useKy } from "../../composable/http";
import { processInsert } from "../../composable/insert";
import { zv } from "../../composable/validator";
import { EditBodySchema } from "../../schemas";
import { factory } from "../factory";

export default factory
  .createApp()
  .post("/", zv("json", EditBodySchema), async (c) => {
    const body = c.req.valid("json");

    const stub = await getStorageStub(c);
    const ky = useKy(c);

    const edits = body.op.filter((op) => op.op !== "insert");
    const inserts = await processInsert(
      ky,
      body.op.filter((op) => op.op === "insert"),
    );

    // Apply edits before inserts. We don't want to allow user to edit newly inserted
    // items by predicting their IDs.
    if (edits.length) {
      await stub.edit(edits);
    }

    const insertedIds: number[] = [];
    if (inserts.length) {
      const insertedItems = await stub.insert(inserts);
      insertedIds.push(...insertedItems.map((item) => item.id));
    }

    return c.json(
      {
        // Return inserted IDs for client
        // Actually I am not sure what else the client would need here.
        // Currently the only use case is to allow client to delete newly inserted items right away.
        insert: {
          ids: insertedIds,
        },
      },
      201,
    );
  });
