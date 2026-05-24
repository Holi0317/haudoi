import { HTTPException } from "hono/http-exception";
import type { ContentfulStatusCode } from "hono/utils/http-status";

export type ErrorDetails = Record<string, unknown>;

export interface ErrorResponseBody {
  code: string;
  message: string;
  details?: ErrorDetails;
}

/**
 * Base application level error class.
 *
 * This class also corresponds to a HTTP error response in JSON.
 *
 * This class is abstract and should be extended by specific error classes.
 */
export class AppError extends HTTPException {
  /**
   * Machine-readable error code.
   * Should be an enum but typed as a string for flexibility.
   */
  public readonly code: string;
  public readonly details?: ErrorDetails;

  public constructor(
    status: ContentfulStatusCode,
    code: string,
    message: string,
    details?: ErrorDetails,
    cause?: unknown,
  ) {
    const body: ErrorResponseBody = details
      ? { code, message, details }
      : { code, message };

    const res = new Response(JSON.stringify(body), {
      status,
      headers: {
        "content-type": "application/json",
      },
    });

    super(status, { message, res, cause });

    this.code = code;
    this.details = details;
  }
}
