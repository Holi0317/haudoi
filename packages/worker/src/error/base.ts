import { HTTPException } from "hono/http-exception";
import type { ContentfulStatusCode } from "hono/utils/http-status";

export type ErrorDetails = Record<string, unknown>;

export type ErrorResponseBody = {
  code: string;
  message: string;
  details?: ErrorDetails;
};

export class AppError extends HTTPException {
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
