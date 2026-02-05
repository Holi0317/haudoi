import { zValidator } from "@hono/zod-validator";
import type { ValidationTargets } from "hono";
import type * as z from "zod/v4/core";
import { ValidationError } from "../error/validation";

/**
 * Custom zValidator with our error formatting.
 */
export const zv = <
  T extends z.$ZodType,
  Target extends keyof ValidationTargets,
>(
  target: Target,
  schema: T,
) =>
  zValidator(target, schema, (result) => {
    if (!result.success) {
      throw new ValidationError(target, result.error);
    }
  });
