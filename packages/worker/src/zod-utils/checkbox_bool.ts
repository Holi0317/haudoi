import * as z from "zod";

/**
 * Type for boolean in form checkbox. Input data type has to be a string or
 * undefined.
 *
 * This is specifically for HTML form checkboxes where unchecked boxes don't
 * send any value (undefined). This function treats undefined as false.
 *
 * `on` will be considered as true
 * undefined (unchecked checkbox) will be considered as false
 *
 * This is specifically designed for `<input type="checkbox">` in HTML forms, where
 * `value` property is omitted (default to `on`).
 */
export function checkboxBool() {
  return z.codec(z.string().optional(), z.boolean(), {
    decode(value) {
      if (value == null) {
        return false; // Unchecked checkbox defaults to false
      }

      return value.toLowerCase() === "on";
    },
    encode(value) {
      if (value === false) {
        return "false";
      }
    },
  });
}
