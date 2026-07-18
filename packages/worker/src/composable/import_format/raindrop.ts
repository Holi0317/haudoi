import * as z from "zod";
import * as zu from "../../zod-utils";
import type { FormatParser } from ".";

// Schema for parsing CSV rows from Raindrop.io export
// Known columns: id, title, note, excerpt, url, folder, tags, created, cover, highlights, favorite
const RaindropCsvRowSchema = z.looseObject({
  title: z.string().nullish(),
  url: zu.httpUrl(),
  note: z.string().nullish(),
  excerpt: z.string().nullish(),
  tags: z.string().nullish(),
  created: zu.isoTimestampMs().optional(),
  folder: z.string().nullish(),
  favorite: z.string().nullish(),
});

/**
 * Parse Raindrop.io CSV export format
 *
 * Columns: id, title, note, excerpt, url, folder, tags, created, cover, highlights, favorite
 * - url -> url
 * - title -> title
 * - created -> created_at (ISO 8601 string -> unix epoch ms)
 * - tags + note -> note field
 * - folder "archive" -> archive: true
 * - folder "Unsorted" or any other -> archive: false
 * - favorite "true" -> favorite: true
 */
export const parseRaindropCsv: FormatParser = (row) => {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const { title, url, note, tags, created, folder, favorite, ...rest } =
    RaindropCsvRowSchema.parse(row);

  const parsedTags = (tags ?? "").split(", ").filter(Boolean);

  const noteParts: string[] = ["[Imported]"];
  if (note) {
    noteParts.push(note);
  }
  const archive = folder?.toLowerCase() === "archive";

  return {
    title: title ?? null,
    url,
    created_at: created,
    archive,
    favorite: favorite === "true",
    note: noteParts.join("\n"),
    tags: parsedTags,
  };
};
