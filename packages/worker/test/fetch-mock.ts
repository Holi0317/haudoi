import { HttpResponse, http } from "msw";
import { server } from "./server";

type HttpMethod = "get" | "post" | "put" | "patch" | "delete" | "head";

type InterceptConfig = {
  path: string;
  method: string;
};

type ReplyOptions = {
  headers?: HeadersInit;
};

let nextInterceptorId = 0;
const pendingInterceptors = new Set<number>();
let netConnectDisabled = false;

function normalizeMethod(method: string): HttpMethod {
  const m = method.toLowerCase();

  if (
    m === "get" ||
    m === "post" ||
    m === "put" ||
    m === "patch" ||
    m === "delete" ||
    m === "head"
  ) {
    return m;
  }

  throw new Error(`Unsupported HTTP method in fetchMock shim: ${method}`);
}

function createReplyBuilder(baseUrl: string, defaultMethod: HttpMethod) {
  return {
    intercept(config: InterceptConfig) {
      const url = new URL(config.path, baseUrl).toString();
      const method = normalizeMethod(config.method || defaultMethod);

      return {
        reply(status: number, body?: BodyInit | null, options?: ReplyOptions) {
          const id = ++nextInterceptorId;
          pendingInterceptors.add(id);

          const resolver = () => {
            pendingInterceptors.delete(id);

            return new HttpResponse(body ?? null, {
              status,
              headers: options?.headers,
            });
          };

          if (method === "get") {
            server.use(http.get(url, resolver, { once: true }));
          } else if (method === "post") {
            server.use(http.post(url, resolver, { once: true }));
          } else if (method === "put") {
            server.use(http.put(url, resolver, { once: true }));
          } else if (method === "patch") {
            server.use(http.patch(url, resolver, { once: true }));
          } else if (method === "delete") {
            server.use(http.delete(url, resolver, { once: true }));
          } else {
            server.use(http.head(url, resolver, { once: true }));
          }
        },
      };
    },
  };
}

export const fetchMock = {
  activate() {},

  disableNetConnect() {
    if (netConnectDisabled) {
      return;
    }

    netConnectDisabled = true;
    server.use(
      http.all("*", () => {
        return HttpResponse.error();
      }),
    );
  },

  enableNetConnect() {
    netConnectDisabled = false;
  },

  get(baseUrl: string) {
    return createReplyBuilder(baseUrl, "get");
  },

  assertNoPendingInterceptors() {
    if (pendingInterceptors.size === 0) {
      return;
    }

    const count = pendingInterceptors.size;
    pendingInterceptors.clear();
    throw new Error(
      `Expected all fetch interceptors to be consumed (${count} pending)`,
    );
  },
};
