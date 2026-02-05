import { AppError } from "./base";

export class InvalidSearchQueryError extends AppError {
  public readonly errors?: string[];

  public constructor(message: string, errors?: string[], cause?: unknown) {
    super(
      400,
      "invalid_search_query",
      message,
      errors ? { errors } : undefined,
      cause,
    );
    this.errors = errors;
  }
}
