import * as z from "zod";
import * as zu from "../../zod-utils";
import { parse } from "@std/csv";
import type { InsertSchema } from "../../schemas";
import type { FormatParser } from ".";

// Schema for parsing CSV rows from Pocket export
// Known columns: title, url, time_added, tags, status
const PocketCsvRowSchema = z.looseObject({
  title: z.string().nullish(),
  url: zu.httpUrl(),
  status: z.string(),
  time_added: z.coerce.number().pipe(zu.unixEpochSec()),
});

/**
 * Parse Pocket CSV export format
 */
export const parsePocketCsv: FormatParser = (body) => {
  const csv = parse(body, {
    skipFirstRow: true,
  });

  const result: Array<z.output<typeof InsertSchema>> = [];
  const errors: string[] = [];
  // Starts from 1 because we are skipping header row.
  // This means the first data row is row 2 in the original file, aligning with what
  // excel would show.
  let i = 1;

  for (const row of csv) {
    i++;
    const parsed = PocketCsvRowSchema.safeParse(row);
    if (!parsed.success) {
      const errorMsg = `Row ${i}: ${z.prettifyError(parsed.error)}`;
      console.warn(`Skipping invalid row in import file: ${errorMsg}`);
      errors.push(errorMsg);
      continue;
    }

    const { title, url, status, time_added, ...rest } = parsed.data;

    const noteParts: string[] = ["[Imported]"];
    for (const [key, value] of Object.entries(rest)) {
      noteParts.push(`${key}: ${value}`);
    }

    result.push({
      title: title ?? null,
      url,
      created_at: time_added,
      archive: status === "archive",
      favorite: false,
      note: noteParts.join("\n"),
    });
  }

  return { items: result, errors };
};
