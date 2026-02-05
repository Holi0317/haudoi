import { AppError } from "./base";

export class UnauthenticatedError extends AppError {
  public constructor() {
    super(401, "unauthenticated", "Unauthenticated");
  }
}

export class AdminForbiddenError extends AppError {
  public constructor() {
    super(403, "forbidden", "Forbidden");
  }
}

export class UserBannedError extends AppError {
  public readonly bannedAt: number;

  public constructor(bannedAt: number) {
    super(403, "user_banned", "Your account has been banned", {
      bannedAt,
    });
    this.bannedAt = bannedAt;
  }
}

export class InternalServerError extends AppError {
  public constructor(message: string = "Internal server error") {
    super(500, "internal_server_error", message);
  }
}
