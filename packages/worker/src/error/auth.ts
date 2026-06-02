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
