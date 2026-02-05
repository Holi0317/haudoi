import { createFactory } from "hono/factory";

export const factory = createFactory<Env>({
  defaultAppOptions: {
    strict: false,
  },
});
