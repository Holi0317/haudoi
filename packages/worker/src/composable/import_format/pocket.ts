import * as z from "zod";
import * as zu from "../../zod-utils";
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
export const parsePocketCsv: FormatParser = (row) => {
  const { title, url, status, time_added, ...rest } =
    PocketCsvRowSchema.parse(row);

  const noteParts: string[] = ["[Imported]"];
  for (const [key, value] of Object.entries(rest)) {
    noteParts.push(`${key}: ${value}`);
  }

  return {
    title: title ?? null,
    url,
    created_at: time_added,
    archive: status === "archive",
    favorite: false,
    note: noteParts.join("\n"),
  };
};
