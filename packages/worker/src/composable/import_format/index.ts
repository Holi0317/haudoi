import type * as z from "zod";
import type { InsertSchema } from "../../schemas";
import { parsePocketCsv } from "./pocket";
import { parseRaindropCsv } from "./raindrop";

export type CsvFormat = "pocket" | "raindrop";

export type FormatParser = (body: string) => {
  items: Array<z.output<typeof InsertSchema>>;
  errors: string[];
};

export function getParser(format: CsvFormat): FormatParser {
  switch (format) {
    case "pocket":
      return parsePocketCsv;
    case "raindrop":
      return parseRaindropCsv;
  }
}
