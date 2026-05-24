import { afterAll, afterEach, beforeAll } from "vitest";
import { assertNoPendingInterceptors, server } from "./server";

beforeAll(() =>
  server.listen({
    onUnhandledRequest: "error",
  }),
);
afterEach(() => {
  assertNoPendingInterceptors();
  server.resetHandlers();
});
afterAll(() => server.close());
