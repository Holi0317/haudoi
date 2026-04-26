import type { ErrorDetails } from "./base";
import { AppError } from "./base";

export class ResourceNotFoundError extends AppError {
  public constructor(
    message: string = "Resource not found",
    details?: ErrorDetails,
  ) {
    super(404, "not_found", message, details);
  }
}
