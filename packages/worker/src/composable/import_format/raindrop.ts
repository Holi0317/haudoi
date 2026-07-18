import * as z from "zod";
import * as zu from "../../zod-utils";
import dayjs from "dayjs";
import type { FormatParser } from ".";

// Schema for parsing CSV rows from Raindrop.io export
// Known columns: id, title, note, excerpt, url, folder, tags, created, cover, highlights, favorite
const RaindropCsvRowSchema = z.looseObject({
  title: z.string().nullish(),
  url: zu.httpUrl(),
  note: z.string().nullish(),
  excerpt: z.string().nullish(),
  tags: z.string().nullish(),
  created: z.string(),
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
  const { title, url, note, tags, created, folder, favorite } =
    RaindropCsvRowSchema.parse(row);

  const createdDate = dayjs(created);
  const created_at = createdDate.isValid() ? createdDate.valueOf() : undefined;

  const noteParts: string[] = ["[Imported]"];
  if (tags) {
    noteParts.push(`tags: ${tags}`);
  }
  if (note) {
    noteParts.push(note);
  }
  const archive = folder?.toLowerCase() === "archive";

  return {
    title: title ?? null,
    url,
    created_at,
    archive,
    favorite: favorite === "true",
    note: noteParts.join("\n"),
  };
};
