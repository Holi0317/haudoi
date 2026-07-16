import { AppError } from "./base";

export class GoogleTokenExchangeError extends AppError {
  public readonly error: string;
  public readonly description: string;

  public constructor(error: string, description: string) {
    const message = `Failed to exchange Google token from code. ${error}: ${description}`;

    super(400, "google_token_exchange_failed", message, {
      error,
      description,
    });

    this.error = error;
    this.description = description;
  }
}
