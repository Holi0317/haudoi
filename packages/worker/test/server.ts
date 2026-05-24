import type { ResponseResolver } from "msw";
import { setupServer } from "msw/node";

export const server = setupServer();

let nextInterceptorId = 0;
const pendingInterceptors = new Set<number>();

export function trackOneOffInterceptor(
  resolver: ResponseResolver,
): ResponseResolver {
  const id = ++nextInterceptorId;
  pendingInterceptors.add(id);

  const wrapped = (async (...args: Parameters<ResponseResolver>) => {
    pendingInterceptors.delete(id);
    return resolver(...args);
  }) as ResponseResolver;

  return wrapped;
}

export function assertNoPendingInterceptors() {
  if (pendingInterceptors.size === 0) {
    return;
  }

  const count = pendingInterceptors.size;
  pendingInterceptors.clear();
  throw new Error(
    `Expected all fetch interceptors to be consumed (${count} pending)`,
  );
}
