import { ClientRequestOptions } from "hono/client";

//#region src/router/index.d.ts
declare const app: import("hono/hono-base").HonoBase<Env, import("hono/types").BlankSchema | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
}, "/"> | import("hono/types").MergeSchemaPath<import("hono/types").BlankSchema | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: "You have been successfully logged out!";
      outputFormat: "text";
      status: import("hono/utils/http-status").ContentfulStatusCode;
    };
  };
}, "/logout"> | import("hono/types").MergeSchemaPath<{
  "/login": {
    $get: {
      input: {
        query: {
          redirect?: "/" | "/basic" | "/admin" | "haudoi:" | undefined;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    };
  };
} & {
  "/callback": {
    $get: {
      input: {
        query: {
          code: string;
          state: string;
        } | {
          error: string;
          state: string;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
}, "/google">, "/auth"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {
        name: string;
        version: {
          id: string;
          tag: string;
          timestamp: string;
        };
        session: {
          source: "google";
          name: string;
          login: string;
          avatarUrl: string;
          banned: boolean;
        } | null;
      };
      outputFormat: "json";
      status: import("hono/utils/http-status").ContentfulStatusCode;
    };
  };
} | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {
        query: {
          url: string | string[];
          type?: "social" | "favicon" | undefined;
          dpr?: string | string[] | undefined;
          width?: string | string[] | undefined;
          height?: string | string[] | undefined;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
}, "/image"> | import("hono/types").MergeSchemaPath<{
  "/:id": {
    $get: {
      input: {
        param: {
          id: string;
        };
      };
      output: {
        id: number;
        title: string;
        url: string;
        favorite: boolean;
        archive: boolean;
        created_at: number;
        note: string;
        tags: {
          id: number;
          name: string;
          color: string;
          emoji: string;
          created_at: number;
        }[];
      };
      outputFormat: "json";
      status: import("hono/utils/http-status").ContentfulStatusCode;
    };
  };
}, "/item"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {
        items: {
          id: number;
          name: string;
          color: string;
          emoji: string;
          created_at: number;
        }[];
      };
      outputFormat: "json";
      status: import("hono/utils/http-status").ContentfulStatusCode;
    };
  };
} & {
  "/": {
    $post: {
      input: {
        json: {
          name: string;
          color: string;
          emoji?: string | undefined;
        };
      };
      output: {
        id: number;
        name: string;
        color: string;
        emoji: string;
        created_at: number;
      };
      outputFormat: "json";
      status: 201;
    };
  };
} & {
  "/:id": {
    $patch: {
      input: {
        param: {
          id: string;
        };
      } & {
        json: {
          name?: string | undefined;
          color?: string | undefined;
          emoji?: string | undefined;
        };
      };
      output: {
        id: number;
        name: string;
        color: string;
        emoji: string;
        created_at: number;
      };
      outputFormat: "json";
      status: import("hono/utils/http-status").ContentfulStatusCode;
    };
  };
} & {
  "/:id": {
    $delete: {
      input: {
        param: {
          id: string;
        };
      };
      output: null;
      outputFormat: "body";
      status: 204;
    };
  };
}, "/tag"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {
        query: {
          query?: string | undefined;
          cursor?: string | null | undefined;
          limit?: string | string[] | undefined;
          order?: "created_at_asc" | "created_at_desc" | undefined;
        };
      };
      output: {
        cursor: string | null;
        count: number;
        items: {
          id: number;
          title: string;
          url: string;
          favorite: boolean;
          archive: boolean;
          created_at: number;
          note: string;
          tags: {
            id: number;
            name: string;
            color: string;
            emoji: string;
            created_at: number;
          }[];
        }[];
        hasMore: boolean;
      };
      outputFormat: "json";
      status: import("hono/utils/http-status").ContentfulStatusCode;
    };
  };
}, "/search"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $post: {
      input: {
        json: {
          op: ({
            url: string;
            op: "insert";
            title?: string | null | undefined;
            created_at?: number | undefined;
            archive?: boolean | undefined;
            favorite?: boolean | undefined;
            note?: string | undefined;
            tags?: string[] | undefined;
          } | {
            op: "set_bool";
            id: number;
            field: "archive" | "favorite";
            value: boolean;
          } | {
            op: "set_string";
            id: number;
            field: "note";
            value: string;
          } | {
            op: "set_tags";
            id: number;
            tag_ids?: number[] | undefined;
          } | {
            op: "delete";
            id: number;
          })[];
        };
      };
      output: {
        insert: {
          ids: number[];
        };
      };
      outputFormat: "json";
      status: 201;
    };
  };
}, "/edit"> | import("hono/types").MergeSchemaPath<{
  "/export": {
    $post: {
      input: {};
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/import": {
    $get: {
      input: {};
      output: {
        status: {
          rawId: string;
          workflowId: string;
          startedAt: number;
          completed: {
            completedAt: number;
            processed: number;
            inserted: number;
            errors: string[];
          } | null;
        } | null;
      };
      outputFormat: "json";
      status: import("hono/utils/http-status").ContentfulStatusCode;
    };
  };
} & {
  "/import": {
    $post: {
      input: {
        form: {
          file: File;
          format?: "pocket" | "raindrop" | undefined;
        };
      };
      output: {
        status: {
          rawId: string;
          workflowId: string;
          startedAt: number;
          completed: {
            completedAt: number;
            processed: number;
            inserted: number;
            errors: string[];
          } | null;
        };
      };
      outputFormat: "json";
      status: 201;
    };
  };
}, "/bulk">, "/api"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {
        query: {
          query?: string | undefined;
          cursor?: string | null | undefined;
          limit?: string | string[] | undefined;
          order?: "created_at_asc" | "created_at_desc" | undefined;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} | import("hono/types").MergeSchemaPath<{
  "/": {
    $post: {
      input: {
        form: {
          url: string;
          qs?: string | undefined;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    } | {
      input: {
        form: {
          url: string;
          qs?: string | undefined;
        };
      };
      output: {
        insert: {
          ids: number[];
        };
      };
      outputFormat: "json";
      status: 201;
    };
  };
}, "/insert"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $post: {
      input: {
        form: {
          id: import("hono/types").ParsedFormValue | import("hono/types").ParsedFormValue[];
          qs?: string | undefined;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    };
  };
}, "/archive"> | import("hono/types").MergeSchemaPath<{
  "/:id": {
    $get: {
      input: {
        param: {
          id: string;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/:id": {
    $post: {
      input: {
        param: {
          id: string;
        };
      } & {
        form: {
          tags: import("hono/types").ParsedFormValue | import("hono/types").ParsedFormValue[];
          archive?: string | undefined;
          favorite?: string | undefined;
          note?: string | undefined;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    };
  };
} & {
  "/:id/delete": {
    $post: {
      input: {
        param: {
          id: string;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    };
  };
}, "/edit"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/": {
    $post: {
      input: {
        form: {
          file: File;
          format?: "pocket" | "raindrop" | undefined;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    } | {
      input: {
        form: {
          file: File;
          format?: "pocket" | "raindrop" | undefined;
        };
      };
      output: {
        status: {
          rawId: string;
          workflowId: string;
          startedAt: number;
          completed: {
            completedAt: number;
            processed: number;
            inserted: number;
            errors: string[];
          } | null;
        };
      };
      outputFormat: "json";
      status: 201;
    };
  };
}, "/bulk"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/:id": {
    $get: {
      input: {
        param: {
          id: string;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/": {
    $post: {
      input: {
        form: {
          name: string;
          color: string;
          emoji?: string | undefined;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    };
  };
} & {
  "/:id": {
    $post: {
      input: {
        param: {
          id: string;
        };
      } & {
        form: {
          name?: string | undefined;
          color?: string | undefined;
          emoji?: string | undefined;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    } | {
      input: {
        param: {
          id: string;
        };
      } & {
        form: {
          name?: string | undefined;
          color?: string | undefined;
          emoji?: string | undefined;
        };
      };
      output: {
        id: number;
        name: string;
        color: string;
        emoji: string;
        created_at: number;
      };
      outputFormat: "json";
      status: 100 | 102 | 103 | 200 | 201 | 202 | 203 | 206 | 207 | 208 | 226 | 300 | 301 | 302 | 303 | 305 | 306 | 307 | 308 | 400 | 401 | 402 | 403 | 404 | 405 | 406 | 407 | 408 | 409 | 410 | 411 | 412 | 413 | 414 | 415 | 416 | 417 | 418 | 421 | 422 | 423 | 424 | 425 | 426 | 428 | 429 | 431 | 451 | 500 | 501 | 502 | 503 | 504 | 505 | 506 | 507 | 508 | 510 | 511 | -1;
    };
  };
} & {
  "/:id/delete": {
    $get: {
      input: {
        param: {
          id: string;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/:id/delete": {
    $post: {
      input: {
        param: {
          id: string;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    };
  };
}, "/tags">, "/basic"> | import("hono/types").MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/:uid": {
    $get: {
      input: {
        param: {
          uid: string;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/:uid/vacuum": {
    $post: {
      input: {
        param: {
          uid: string;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/:uid/reset-import": {
    $post: {
      input: {
        param: {
          uid: string;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    } | {
      input: {
        param: {
          uid: string;
        };
      };
      output: "User not found";
      outputFormat: "text";
      status: 404;
    };
  };
} & {
  "/:uid/delete": {
    $get: {
      input: {
        param: {
          uid: string;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/:uid/delete": {
    $post: {
      input: {
        param: {
          uid: string;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  };
} & {
  "/:uid/ban": {
    $post: {
      input: {
        param: {
          uid: string;
        };
      } & {
        form: {
          banned: "false" | "true";
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    } | {
      input: {
        param: {
          uid: string;
        };
      } & {
        form: {
          banned: "false" | "true";
        };
      };
      output: "User not found";
      outputFormat: "text";
      status: 404;
    };
  };
}, "/admin">, "/", "*">;
type AppType = typeof app;
//#endregion
//#region src/client/index.d.ts
/**
 * Type for hono client. For type inference with InferRequestType and InferResponseType.
 */
type ClientType = ReturnType<typeof createClient>;
/**
 * Create a Hono client for the worker app.
 *
 * Basically a wrapper around {@link hc} from `hono/client`.
 */
declare function createClient<Prefix extends string = string>(baseUrl: Prefix, options?: ClientRequestOptions): {
  index: import("hono/client").ClientRequest<string, "/", {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  }>;
} & {
  auth: {
    logout: import("hono/client").ClientRequest<string, "/auth/logout", {
      $get: {
        input: {};
        output: "You have been successfully logged out!";
        outputFormat: "text";
        status: import("hono/utils/http-status").ContentfulStatusCode;
      };
    }>;
  };
} & {
  auth: {
    google: {
      login: import("hono/client").ClientRequest<string, "/auth/google/login", {
        $get: {
          input: {
            query: {
              redirect?: "/" | "/basic" | "/admin" | "haudoi:" | undefined;
            };
          };
          output: undefined;
          outputFormat: "redirect";
          status: 302;
        };
      }>;
    };
  };
} & {
  auth: {
    google: {
      callback: import("hono/client").ClientRequest<string, "/auth/google/callback", {
        $get: {
          input: {
            query: {
              code: string;
              state: string;
            } | {
              error: string;
              state: string;
            };
          };
          output: {};
          outputFormat: string;
          status: import("hono/utils/http-status").StatusCode;
        };
      }>;
    };
  };
} & {
  api: import("hono/client").ClientRequest<string, "/api", {
    $get: {
      input: {};
      output: {
        name: string;
        version: {
          id: string;
          tag: string;
          timestamp: string;
        };
        session: {
          source: "google";
          name: string;
          login: string;
          avatarUrl: string;
          banned: boolean;
        } | null;
      };
      outputFormat: "json";
      status: import("hono/utils/http-status").ContentfulStatusCode;
    };
  }>;
} & {
  api: {
    image: import("hono/client").ClientRequest<string, "/api/image", {
      $get: {
        input: {
          query: {
            url: string | string[];
            type?: "social" | "favicon" | undefined;
            dpr?: string | string[] | undefined;
            width?: string | string[] | undefined;
            height?: string | string[] | undefined;
          };
        };
        output: {};
        outputFormat: string;
        status: import("hono/utils/http-status").StatusCode;
      };
    }>;
  };
} & {
  api: {
    item: {
      ":id": import("hono/client").ClientRequest<string, "/api/item/:id", {
        $get: {
          input: {
            param: {
              id: string;
            };
          };
          output: {
            id: number;
            title: string;
            url: string;
            favorite: boolean;
            archive: boolean;
            created_at: number;
            note: string;
            tags: {
              id: number;
              name: string;
              color: string;
              emoji: string;
              created_at: number;
            }[];
          };
          outputFormat: "json";
          status: import("hono/utils/http-status").ContentfulStatusCode;
        };
      }>;
    };
  };
} & {
  api: {
    tag: import("hono/client").ClientRequest<string, "/api/tag", {
      $get: {
        input: {};
        output: {
          items: {
            id: number;
            name: string;
            color: string;
            emoji: string;
            created_at: number;
          }[];
        };
        outputFormat: "json";
        status: import("hono/utils/http-status").ContentfulStatusCode;
      };
      $post: {
        input: {
          json: {
            name: string;
            color: string;
            emoji?: string | undefined;
          };
        };
        output: {
          id: number;
          name: string;
          color: string;
          emoji: string;
          created_at: number;
        };
        outputFormat: "json";
        status: 201;
      };
    }>;
  };
} & {
  api: {
    tag: {
      ":id": import("hono/client").ClientRequest<string, "/api/tag/:id", {
        $patch: {
          input: {
            param: {
              id: string;
            };
          } & {
            json: {
              name?: string | undefined;
              color?: string | undefined;
              emoji?: string | undefined;
            };
          };
          output: {
            id: number;
            name: string;
            color: string;
            emoji: string;
            created_at: number;
          };
          outputFormat: "json";
          status: import("hono/utils/http-status").ContentfulStatusCode;
        };
        $delete: {
          input: {
            param: {
              id: string;
            };
          };
          output: null;
          outputFormat: "body";
          status: 204;
        };
      }>;
    };
  };
} & {
  api: {
    search: import("hono/client").ClientRequest<string, "/api/search", {
      $get: {
        input: {
          query: {
            query?: string | undefined;
            cursor?: string | null | undefined;
            limit?: string | string[] | undefined;
            order?: "created_at_asc" | "created_at_desc" | undefined;
          };
        };
        output: {
          cursor: string | null;
          count: number;
          items: {
            id: number;
            title: string;
            url: string;
            favorite: boolean;
            archive: boolean;
            created_at: number;
            note: string;
            tags: {
              id: number;
              name: string;
              color: string;
              emoji: string;
              created_at: number;
            }[];
          }[];
          hasMore: boolean;
        };
        outputFormat: "json";
        status: import("hono/utils/http-status").ContentfulStatusCode;
      };
    }>;
  };
} & {
  api: {
    edit: import("hono/client").ClientRequest<string, "/api/edit", {
      $post: {
        input: {
          json: {
            op: ({
              url: string;
              op: "insert";
              title?: string | null | undefined;
              created_at?: number | undefined;
              archive?: boolean | undefined;
              favorite?: boolean | undefined;
              note?: string | undefined;
              tags?: string[] | undefined;
            } | {
              op: "set_bool";
              id: number;
              field: "archive" | "favorite";
              value: boolean;
            } | {
              op: "set_string";
              id: number;
              field: "note";
              value: string;
            } | {
              op: "set_tags";
              id: number;
              tag_ids?: number[] | undefined;
            } | {
              op: "delete";
              id: number;
            })[];
          };
        };
        output: {
          insert: {
            ids: number[];
          };
        };
        outputFormat: "json";
        status: 201;
      };
    }>;
  };
} & {
  api: {
    bulk: {
      export: import("hono/client").ClientRequest<string, "/api/bulk/export", {
        $post: {
          input: {};
          output: {};
          outputFormat: string;
          status: import("hono/utils/http-status").StatusCode;
        };
      }>;
    };
  };
} & {
  api: {
    bulk: {
      import: import("hono/client").ClientRequest<string, "/api/bulk/import", {
        $get: {
          input: {};
          output: {
            status: {
              rawId: string;
              workflowId: string;
              startedAt: number;
              completed: {
                completedAt: number;
                processed: number;
                inserted: number;
                errors: string[];
              } | null;
            } | null;
          };
          outputFormat: "json";
          status: import("hono/utils/http-status").ContentfulStatusCode;
        };
        $post: {
          input: {
            form: {
              file: File;
              format?: "pocket" | "raindrop" | undefined;
            };
          };
          output: {
            status: {
              rawId: string;
              workflowId: string;
              startedAt: number;
              completed: {
                completedAt: number;
                processed: number;
                inserted: number;
                errors: string[];
              } | null;
            };
          };
          outputFormat: "json";
          status: 201;
        };
      }>;
    };
  };
} & {
  basic: import("hono/client").ClientRequest<string, "/basic", {
    $get: {
      input: {
        query: {
          query?: string | undefined;
          cursor?: string | null | undefined;
          limit?: string | string[] | undefined;
          order?: "created_at_asc" | "created_at_desc" | undefined;
        };
      };
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  }>;
} & {
  basic: {
    insert: import("hono/client").ClientRequest<string, "/basic/insert", {
      $post: {
        input: {
          form: {
            url: string;
            qs?: string | undefined;
          };
        };
        output: undefined;
        outputFormat: "redirect";
        status: 302;
      } | {
        input: {
          form: {
            url: string;
            qs?: string | undefined;
          };
        };
        output: {
          insert: {
            ids: number[];
          };
        };
        outputFormat: "json";
        status: 201;
      };
    }>;
  };
} & {
  basic: {
    archive: import("hono/client").ClientRequest<string, "/basic/archive", {
      $post: {
        input: {
          form: {
            id: import("hono/types").ParsedFormValue | import("hono/types").ParsedFormValue[];
            qs?: string | undefined;
          };
        };
        output: undefined;
        outputFormat: "redirect";
        status: 302;
      };
    }>;
  };
} & {
  basic: {
    edit: {
      ":id": import("hono/client").ClientRequest<string, "/basic/edit/:id", {
        $get: {
          input: {
            param: {
              id: string;
            };
          };
          output: {};
          outputFormat: string;
          status: import("hono/utils/http-status").StatusCode;
        };
        $post: {
          input: {
            param: {
              id: string;
            };
          } & {
            form: {
              tags: import("hono/types").ParsedFormValue | import("hono/types").ParsedFormValue[];
              archive?: string | undefined;
              favorite?: string | undefined;
              note?: string | undefined;
            };
          };
          output: undefined;
          outputFormat: "redirect";
          status: 302;
        };
      }>;
    };
  };
} & {
  basic: {
    edit: {
      ":id": {
        delete: import("hono/client").ClientRequest<string, "/basic/edit/:id/delete", {
          $post: {
            input: {
              param: {
                id: string;
              };
            };
            output: undefined;
            outputFormat: "redirect";
            status: 302;
          };
        }>;
      };
    };
  };
} & {
  basic: {
    bulk: import("hono/client").ClientRequest<string, "/basic/bulk", {
      $get: {
        input: {};
        output: {};
        outputFormat: string;
        status: import("hono/utils/http-status").StatusCode;
      };
      $post: {
        input: {
          form: {
            file: File;
            format?: "pocket" | "raindrop" | undefined;
          };
        };
        output: undefined;
        outputFormat: "redirect";
        status: 302;
      } | {
        input: {
          form: {
            file: File;
            format?: "pocket" | "raindrop" | undefined;
          };
        };
        output: {
          status: {
            rawId: string;
            workflowId: string;
            startedAt: number;
            completed: {
              completedAt: number;
              processed: number;
              inserted: number;
              errors: string[];
            } | null;
          };
        };
        outputFormat: "json";
        status: 201;
      };
    }>;
  };
} & {
  basic: {
    tags: import("hono/client").ClientRequest<string, "/basic/tags", {
      $get: {
        input: {};
        output: {};
        outputFormat: string;
        status: import("hono/utils/http-status").StatusCode;
      };
      $post: {
        input: {
          form: {
            name: string;
            color: string;
            emoji?: string | undefined;
          };
        };
        output: undefined;
        outputFormat: "redirect";
        status: 302;
      };
    }>;
  };
} & {
  basic: {
    tags: {
      ":id": import("hono/client").ClientRequest<string, "/basic/tags/:id", {
        $get: {
          input: {
            param: {
              id: string;
            };
          };
          output: {};
          outputFormat: string;
          status: import("hono/utils/http-status").StatusCode;
        };
        $post: {
          input: {
            param: {
              id: string;
            };
          } & {
            form: {
              name?: string | undefined;
              color?: string | undefined;
              emoji?: string | undefined;
            };
          };
          output: undefined;
          outputFormat: "redirect";
          status: 302;
        } | {
          input: {
            param: {
              id: string;
            };
          } & {
            form: {
              name?: string | undefined;
              color?: string | undefined;
              emoji?: string | undefined;
            };
          };
          output: {
            id: number;
            name: string;
            color: string;
            emoji: string;
            created_at: number;
          };
          outputFormat: "json";
          status: 100 | 102 | 103 | 200 | 201 | 202 | 203 | 206 | 207 | 208 | 226 | 300 | 301 | 302 | 303 | 305 | 306 | 307 | 308 | 400 | 401 | 402 | 403 | 404 | 405 | 406 | 407 | 408 | 409 | 410 | 411 | 412 | 413 | 414 | 415 | 416 | 417 | 418 | 421 | 422 | 423 | 424 | 425 | 426 | 428 | 429 | 431 | 451 | 500 | 501 | 502 | 503 | 504 | 505 | 506 | 507 | 508 | 510 | 511 | -1;
        };
      }>;
    };
  };
} & {
  basic: {
    tags: {
      ":id": {
        delete: import("hono/client").ClientRequest<string, "/basic/tags/:id/delete", {
          $get: {
            input: {
              param: {
                id: string;
              };
            };
            output: {};
            outputFormat: string;
            status: import("hono/utils/http-status").StatusCode;
          };
          $post: {
            input: {
              param: {
                id: string;
              };
            };
            output: undefined;
            outputFormat: "redirect";
            status: 302;
          };
        }>;
      };
    };
  };
} & {
  admin: import("hono/client").ClientRequest<string, "/admin", {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: import("hono/utils/http-status").StatusCode;
    };
  }>;
} & {
  admin: {
    ":uid": import("hono/client").ClientRequest<string, "/admin/:uid", {
      $get: {
        input: {
          param: {
            uid: string;
          };
        };
        output: {};
        outputFormat: string;
        status: import("hono/utils/http-status").StatusCode;
      };
    }>;
  };
} & {
  admin: {
    ":uid": {
      vacuum: import("hono/client").ClientRequest<string, "/admin/:uid/vacuum", {
        $post: {
          input: {
            param: {
              uid: string;
            };
          };
          output: {};
          outputFormat: string;
          status: import("hono/utils/http-status").StatusCode;
        };
      }>;
    };
  };
} & {
  admin: {
    ":uid": {
      "reset-import": import("hono/client").ClientRequest<string, "/admin/:uid/reset-import", {
        $post: {
          input: {
            param: {
              uid: string;
            };
          };
          output: undefined;
          outputFormat: "redirect";
          status: 302;
        } | {
          input: {
            param: {
              uid: string;
            };
          };
          output: "User not found";
          outputFormat: "text";
          status: 404;
        };
      }>;
    };
  };
} & {
  admin: {
    ":uid": {
      delete: import("hono/client").ClientRequest<string, "/admin/:uid/delete", {
        $get: {
          input: {
            param: {
              uid: string;
            };
          };
          output: {};
          outputFormat: string;
          status: import("hono/utils/http-status").StatusCode;
        };
        $post: {
          input: {
            param: {
              uid: string;
            };
          };
          output: {};
          outputFormat: string;
          status: import("hono/utils/http-status").StatusCode;
        };
      }>;
    };
  };
} & {
  admin: {
    ":uid": {
      ban: import("hono/client").ClientRequest<string, "/admin/:uid/ban", {
        $post: {
          input: {
            param: {
              uid: string;
            };
          } & {
            form: {
              banned: "false" | "true";
            };
          };
          output: undefined;
          outputFormat: "redirect";
          status: 302;
        } | {
          input: {
            param: {
              uid: string;
            };
          } & {
            form: {
              banned: "false" | "true";
            };
          };
          output: "User not found";
          outputFormat: "text";
          status: 404;
        };
      }>;
    };
  };
};
//#endregion
export { type AppType, ClientType, createClient };