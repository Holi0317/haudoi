import { z } from "zod";

/**
 * Validates a query string.
 *
 * The value is safe to append to a URL via string concatenation.
 *
 * Rules:
 * - default to empty string when input is `undefined`/`null`
 * - empty string is valid
 * - if non-empty, must start with `?`
 * - disallow CR/LF
 * - skip URL parsing when empty
 */
export const queryString = () =>
  z
    .string()
    .max(2000, { message: "query string too long" })
    .refine((s) => !s.includes("\n") && !s.includes("\r"), {
      message: "must not contain CR or LF",
    })
    .refine((s) => s === "" || s.startsWith("?"), {
      message: "must start with '?' or be empty",
    })
    .refine(
      (s) => {
        if (s === "") {
          return true;
        }

        try {
          const url = new URL("http://example.invalid" + s);
          return url.search === s;
        } catch {
          return false;
        }
      },
      { message: "invalid query string format" },
    )
    .prefault("");

export type QueryString = z.infer<typeof queryString>;
