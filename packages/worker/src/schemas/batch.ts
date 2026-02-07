import * as z from "zod";
import * as zu from "../zod-utils";

/**
 * Info/statistics about completed import
 */
export const ImportCompletedSchema = z.object({
  /**
   * When the import completed
   */
  completedAt: zu.unixEpochMs(),
  /**
   * Number of processed rows from source file
   */
  processed: z.number(),
  /**
   * Number of inserted rows. This can be less than processed due to deduplication
   */
  inserted: z.number(),
  /**
   * Errors encountered during import
   */
  errors: z.array(z.string()),
});

/**
 * Schema for import status in storage DO
 */
export const ImportStatusSchema = z.object({
  /**
   * ID for raw file upload stored in KV
   */
  rawId: z.string(),

  /**
   * ID for the import workflow.
   *
   * Querying this workflow ID might give empty result if the workflow log
   * has already been purged.
   */
  workflowId: z.string(),

  /**
   * When the import started
   */
  startedAt: zu.unixEpochMs(),

  /**
   * Complete status. Null if the import workflow is still in progress.
   */
  completed: ImportCompletedSchema.nullable(),
});
