import { AppError } from "./base";

export class GitHubTokenExchangeError extends AppError {
  public readonly error: string;
  public readonly description: string;

  public constructor(error: string, description: string) {
    const message = `Failed to exchange github token from code. ${error}: ${description}`;

    super(400, "github_token_exchange_failed", message, {
      error,
      description,
    });

    this.error = error;
    this.description = description;
  }
}
