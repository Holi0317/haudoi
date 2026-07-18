import type { WorkflowEvent, WorkflowStep } from "cloudflare:workers";
import { WorkflowEntrypoint } from "cloudflare:workers";
import { uidToString, type UserIdentifier } from "../composable/user/ident";
import { useImportStore, type CsvFormat } from "../composable/import";
import { getImportStubAdmin, getStorageStubAdmin } from "../composable/do";
import { useBasicKy } from "../composable/http";
import { processInsert } from "../composable/insert";

export interface ImportWorkflowParams {
  uid: UserIdentifier;
  rawId: string;
  format: CsvFormat;
}

export class ImportWorkflow extends WorkflowEntrypoint<
  CloudflareBindings,
  ImportWorkflowParams
> {
  public async run(
    event: WorkflowEvent<ImportWorkflowParams>,
    step: WorkflowStep,
  ) {
    const { uid, rawId, format } = event.payload;
    const uidStr = uidToString(uid);

    console.log("Starting import workflow", { uid, rawId });

    // Step 1: Parse and partition raw import file
    const { parts, stats } = await step.do(
      "Partition raw import file",
      async () => {
        const { partition } = useImportStore(this.env);
        return await partition(uid, rawId, format);
      },
    );

    // Step 2: Prepare insert objects for each part (resolve titles)
    for (const partId of parts) {
      await step.do(`Prepare part ${partId}`, async () => {
        console.log(`Preparing chunk for user ${uidStr}: ${partId}`);

        const { readPart, writePrepared } = useImportStore(this.env);
        const ky = useBasicKy(this.env);

        const part = await readPart(uid, partId);

        console.log("Resolving insert items titles");
        const inserts = await processInsert(ky, part.items);

        console.log("Writing prepared insert items to KV");
        await writePrepared(uid, partId, inserts);
      });
    }

    // Step 3: Insert all prepared items at once (for accurate deduplication)
    const { insertedCount } = await step.do("Insert all links", async () => {
      const { readPrepared } = useImportStore(this.env);
      const stub = getStorageStubAdmin(this.env, uid);

      // Collect all prepared items from all parts
      const promises = await Promise.all(
        parts.map((partId) => readPrepared(uid, partId)),
      );

      const items = promises.flatMap((p) => p.items);

      console.log(
        `Inserting ${items.length} items into storage for user ${uidStr}`,
      );
      const inserted = await stub.insert(items);

      return {
        insertedCount: inserted.length,
      };
    });

    console.log("Import workflow completed. Marking on durable object", {
      uid,
      rawId,
      stats,
      insertedCount,
    });

    await step.do("Mark import as complete", async () => {
      const stub = getImportStubAdmin(this.env, uid);
      await stub.complete({
        completedAt: Date.now(),
        processed: stats.validRows,
        inserted: insertedCount,
        errors: stats.parseErrors,
      });
    });

    await step.do("Clear raw and part data", async () => {
      const { clearRaw, clearPart, clearPrepared } = useImportStore(this.env);

      await clearRaw(rawId);
      await clearPart(uid);
      await clearPrepared(uid);
    });
  }
}
