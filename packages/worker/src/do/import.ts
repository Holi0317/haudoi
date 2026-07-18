import { DurableObject } from "cloudflare:workers";
import type * as z from "zod";
import { useSingleKV } from "../composable/do_kv";
import type { ImportCompletedSchema } from "../schemas";
import { ImportStatusSchema } from "../schemas";
import type { UserIdentifier } from "../composable/user/ident";
import type { CsvFormatSchema } from "../composable/import_format";

function useStatus(ctx: DurableObjectState) {
  return useSingleKV(ctx, "status", ImportStatusSchema);
}

/**
 * Durable object for handling import related operation and tracking state.
 *
 * This should be bound per user.
 */
export class ImportDO extends DurableObject<CloudflareBindings> {
  /**
   * Get current import status.
   *
   * @returns null if the user never started an import;
   * returns the last import status otherwise.
   */
  public async status() {
    const { get } = useStatus(this.ctx);

    return get();
  }

  /**
   * Start an import workflow.
   *
   * @param uid User identifier for this durable object
   * @param rawId Raw import file in KV
   * @param format CSV format of the import file (pocket or raindrop)
   * @returns Import status object
   * @throws Error if another import is already in progress
   */
  public async start(
    uid: UserIdentifier,
    rawId: string,
    format: CsvFormatSchema,
  ) {
    const { get, put } = useStatus(this.ctx);

    return await this.ctx.blockConcurrencyWhile(async () => {
      const status = get();

      if (status && status.completed == null) {
        throw new Error("Another import already in progress");
      }

      const wf = await this.env.IMPORT_WORKFLOW.create({
        params: {
          uid,
          rawId,
          format,
        },
      });

      const s: z.output<typeof ImportStatusSchema> = {
        rawId,
        workflowId: wf.id,
        startedAt: Date.now(),
        completed: null,
      };

      put(s);

      return s;
    });
  }

  /**
   * Reset current import status, also try to cancel the ongoing import workflow if possible.
   *
   * This should only get called by admin.
   */
  public async reset() {
    const { get, delete_ } = useStatus(this.ctx);

    await this.ctx.blockConcurrencyWhile(async () => {
      const status = get();

      if (status == null || status.completed != null) {
        // No import in progress
        delete_();
        return;
      }

      try {
        const wf = await this.env.IMPORT_WORKFLOW.get(status.workflowId);
        await wf.terminate();
      } catch (err) {
        console.warn(
          `Failed to terminate import workflow ${status.workflowId}`,
          err,
        );
      }

      delete_();
    });
  }

  /**
   * Mark current import as complete.
   *
   * This should only get called by the import workflow.
   *
   * @throws Error if no import is in progress.
   */
  public async complete(info: z.output<typeof ImportCompletedSchema>) {
    const { get, put } = useStatus(this.ctx);

    await this.ctx.blockConcurrencyWhile(async () => {
      const status = get();

      if (!status) {
        throw new Error("No import in progress");
      }

      put({
        ...status,
        completed: info,
      });
    });
  }
}
