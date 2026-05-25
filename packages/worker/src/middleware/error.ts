import type { ErrorHandler } from "hono";
import { AppError } from "../error/base";
import { InternalServerError } from "../error/internal";

function wrapError(err: unknown): AppError {
  if (err instanceof AppError) {
    return err;
  }

  return new InternalServerError(err);
}

export const errorHandler: ErrorHandler = (err) => {
  const e = wrapError(err);

  return e.getResponse();
};
