import type { ValidationTargets } from "hono";
import * as z from "zod/v4/core";
import { AppError } from "./base";

export class ValidationError extends AppError {
  public readonly target: keyof ValidationTargets;
  public readonly pretty: string;
  public readonly issues: z.$ZodIssue[];

  public constructor(target: keyof ValidationTargets, zodError: z.$ZodError) {
    const pretty = z.prettifyError(zodError);
    const issues = zodError.issues;

    super(
      400,
      "validation_error",
      `Failed to parse or validate ${target}`,
      {
        target,
        pretty,
        issues,
      },
      zodError,
    );

    this.target = target;
    this.pretty = pretty;
    this.issues = issues;
  }
}
