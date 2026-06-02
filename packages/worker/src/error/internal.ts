import { AppError } from "./base";

export class InternalServerError extends AppError {
  public constructor(err: unknown) {
    const message = err instanceof Error ? err.message : "Unknown error";
    const details = err instanceof Error ? { name: err.name } : undefined;

    super(500, "internal_server_error", message, details, err);
  }
}
