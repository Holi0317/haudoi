import * as z from "zod";
import { InsertSchema } from "../../schemas";
import { parsePocketCsv } from "./pocket";
import { parseRaindropCsv } from "./raindrop";
import { parse } from "@std/csv";

export const CsvFormat = z.enum(["pocket", "raindrop"]);

export type CsvFormatSchema = z.output<typeof CsvFormat>;

export type FormatParser = (
  row: Record<string, string>,
  i: number,
) => z.input<typeof InsertSchema>;

export function getParser(format: CsvFormatSchema): FormatParser {
  switch (format) {
    case "pocket":
      return parsePocketCsv;
    case "raindrop":
      return parseRaindropCsv;
    default:
      throw new Error(`Unsupported format ${format}`);
  }
}

export function parseFormat(format: CsvFormatSchema, body: string) {
  const p = getParser(format);

  const csv = parse(body, {
    skipFirstRow: true,
  });

  const items: Array<z.output<typeof InsertSchema>> = [];
  const errors: string[] = [];

  // Starts from 1 because we are skipping header row.
  // This means the first data row is row 2 in the original file, aligning with what
  // excel would show.
  let i = 1;

  for (const row of csv) {
    i++;

    try {
      const inp = p(row, i);

      const parsed = InsertSchema.parse(inp);
      items.push(parsed);
    } catch (err) {
      const msg =
        err instanceof z.ZodError ? z.prettifyError(err) : String(err);

      console.warn(`Skipping invalid row in import file. Row ${i}: ${msg}`);

      errors.push(`Row ${i}: ${msg}`);
    }
  }

  return {
    items,
    errors,
  };
}
