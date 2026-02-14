import * as hono_client0 from "hono/client";
import { ClientRequestOptions } from "hono/client";
import * as hono_utils_http_status20 from "hono/utils/http-status";
import * as hono_types1 from "hono/types";
import * as hono_hono_base0 from "hono/hono-base";

//#region src/router/index.d.ts
declare const app: hono_hono_base0.HonoBase<Env, hono_types1.BlankSchema | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status20.StatusCode;
    };
  };
}, "/"> | hono_types1.MergeSchemaPath<hono_types1.BlankSchema | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: "You have been successfully logged out!";
      outputFormat: "text";
      status: hono_utils_http_status20.ContentfulStatusCode;
    };
  };
}, "/logout"> | hono_types1.MergeSchemaPath<{
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
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    } | {
      input: {
        query: {
          code: string;
          state: string;
        };
      };
      output: "Invalid or expired state parameter";
      outputFormat: "text";
      status: 400;
    };
  };
}, "/github">, "/auth"> | hono_types1.MergeSchemaPath<{
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
          source: "github";
          name: string;
          login: string;
          avatarUrl: string;
          banned: boolean;
        } | null;
      };
      outputFormat: "json";
      status: hono_utils_http_status20.ContentfulStatusCode;
    };
  };
} | hono_types1.MergeSchemaPath<{
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
      status: hono_utils_http_status20.StatusCode;
    };
  };
}, "/image"> | hono_types1.MergeSchemaPath<{
  "/:id": {
    $get: {
      input: {
        param: {
          id: string;
        };
      };
      output: {
        message: string;
      };
      outputFormat: "json";
      status: 404;
    } | {
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
      };
      outputFormat: "json";
      status: hono_utils_http_status20.ContentfulStatusCode;
    };
  };
}, "/item"> | hono_types1.MergeSchemaPath<{
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
      status: hono_utils_http_status20.ContentfulStatusCode;
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
        message: string;
      };
      outputFormat: "json";
      status: 404;
    } | {
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
      status: hono_utils_http_status20.ContentfulStatusCode;
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
}, "/tag"> | hono_types1.MergeSchemaPath<{
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
      status: hono_utils_http_status20.ContentfulStatusCode;
    };
  };
}, "/search"> | hono_types1.MergeSchemaPath<{
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
}, "/edit"> | hono_types1.MergeSchemaPath<{
  "/export": {
    $post: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status20.StatusCode;
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
      status: hono_utils_http_status20.ContentfulStatusCode;
    };
  };
} & {
  "/import": {
    $post: {
      input: {
        form: {
          file: File;
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
}, "/bulk">, "/api"> | hono_types1.MergeSchemaPath<{
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
      status: hono_utils_http_status20.StatusCode;
    };
  };
} | hono_types1.MergeSchemaPath<{
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
}, "/insert"> | hono_types1.MergeSchemaPath<{
  "/": {
    $post: {
      input: {
        form: {
          id: hono_types1.ParsedFormValue | hono_types1.ParsedFormValue[];
          qs?: string | undefined;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    };
  };
}, "/archive"> | hono_types1.MergeSchemaPath<{
  "/:id": {
    $get: {
      input: {
        param: {
          id: string;
        };
      };
      output: {};
      outputFormat: string;
      status: hono_utils_http_status20.StatusCode;
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
}, "/edit"> | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status20.StatusCode;
    };
  };
} & {
  "/": {
    $post: {
      input: {
        form: {
          file: File;
        };
      };
      output: undefined;
      outputFormat: "redirect";
      status: 302;
    } | {
      input: {
        form: {
          file: File;
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
}, "/bulk"> | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status20.StatusCode;
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
      status: hono_utils_http_status20.StatusCode;
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
      } | {
        message: string;
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
      status: hono_utils_http_status20.StatusCode;
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
}, "/tags">, "/basic"> | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status20.StatusCode;
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
      status: hono_utils_http_status20.StatusCode;
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
      status: hono_utils_http_status20.StatusCode;
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
      status: hono_utils_http_status20.StatusCode;
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
      status: hono_utils_http_status20.StatusCode;
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
  index: hono_client0.ClientRequest<string, "/", {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status20.StatusCode;
    };
  }>;
} & {
  auth: {
    logout: hono_client0.ClientRequest<string, "/auth/logout", {
      $get: {
        input: {};
        output: "You have been successfully logged out!";
        outputFormat: "text";
        status: hono_utils_http_status20.ContentfulStatusCode;
      };
    }>;
  };
} & {
  auth: {
    github: {
      login: hono_client0.ClientRequest<string, "/auth/github/login", {
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
    github: {
      callback: hono_client0.ClientRequest<string, "/auth/github/callback", {
        $get: {
          input: {
            query: {
              code: string;
              state: string;
            };
          };
          output: undefined;
          outputFormat: "redirect";
          status: 302;
        } | {
          input: {
            query: {
              code: string;
              state: string;
            };
          };
          output: "Invalid or expired state parameter";
          outputFormat: "text";
          status: 400;
        };
      }>;
    };
  };
} & {
  api: hono_client0.ClientRequest<string, "/api", {
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
          source: "github";
          name: string;
          login: string;
          avatarUrl: string;
          banned: boolean;
        } | null;
      };
      outputFormat: "json";
      status: hono_utils_http_status20.ContentfulStatusCode;
    };
  }>;
} & {
  api: {
    image: hono_client0.ClientRequest<string, "/api/image", {
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
        status: hono_utils_http_status20.StatusCode;
      };
    }>;
  };
} & {
  api: {
    item: {
      ":id": hono_client0.ClientRequest<string, "/api/item/:id", {
        $get: {
          input: {
            param: {
              id: string;
            };
          };
          output: {
            message: string;
          };
          outputFormat: "json";
          status: 404;
        } | {
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
          };
          outputFormat: "json";
          status: hono_utils_http_status20.ContentfulStatusCode;
        };
      }>;
    };
  };
} & {
  api: {
    tag: hono_client0.ClientRequest<string, "/api/tag", {
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
        status: hono_utils_http_status20.ContentfulStatusCode;
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
      ":id": hono_client0.ClientRequest<string, "/api/tag/:id", {
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
            message: string;
          };
          outputFormat: "json";
          status: 404;
        } | {
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
          status: hono_utils_http_status20.ContentfulStatusCode;
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
    search: hono_client0.ClientRequest<string, "/api/search", {
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
        status: hono_utils_http_status20.ContentfulStatusCode;
      };
    }>;
  };
} & {
  api: {
    edit: hono_client0.ClientRequest<string, "/api/edit", {
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
      export: hono_client0.ClientRequest<string, "/api/bulk/export", {
        $post: {
          input: {};
          output: {};
          outputFormat: string;
          status: hono_utils_http_status20.StatusCode;
        };
      }>;
    };
  };
} & {
  api: {
    bulk: {
      import: hono_client0.ClientRequest<string, "/api/bulk/import", {
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
          status: hono_utils_http_status20.ContentfulStatusCode;
        };
        $post: {
          input: {
            form: {
              file: File;
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
  basic: hono_client0.ClientRequest<string, "/basic", {
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
      status: hono_utils_http_status20.StatusCode;
    };
  }>;
} & {
  basic: {
    insert: hono_client0.ClientRequest<string, "/basic/insert", {
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
    archive: hono_client0.ClientRequest<string, "/basic/archive", {
      $post: {
        input: {
          form: {
            id: hono_types1.ParsedFormValue | hono_types1.ParsedFormValue[];
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
      ":id": hono_client0.ClientRequest<string, "/basic/edit/:id", {
        $get: {
          input: {
            param: {
              id: string;
            };
          };
          output: {};
          outputFormat: string;
          status: hono_utils_http_status20.StatusCode;
        };
        $post: {
          input: {
            param: {
              id: string;
            };
          } & {
            form: {
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
        delete: hono_client0.ClientRequest<string, "/basic/edit/:id/delete", {
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
    bulk: hono_client0.ClientRequest<string, "/basic/bulk", {
      $get: {
        input: {};
        output: {};
        outputFormat: string;
        status: hono_utils_http_status20.StatusCode;
      };
      $post: {
        input: {
          form: {
            file: File;
          };
        };
        output: undefined;
        outputFormat: "redirect";
        status: 302;
      } | {
        input: {
          form: {
            file: File;
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
    tags: hono_client0.ClientRequest<string, "/basic/tags", {
      $get: {
        input: {};
        output: {};
        outputFormat: string;
        status: hono_utils_http_status20.StatusCode;
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
      ":id": hono_client0.ClientRequest<string, "/basic/tags/:id", {
        $get: {
          input: {
            param: {
              id: string;
            };
          };
          output: {};
          outputFormat: string;
          status: hono_utils_http_status20.StatusCode;
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
          } | {
            message: string;
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
        delete: hono_client0.ClientRequest<string, "/basic/tags/:id/delete", {
          $get: {
            input: {
              param: {
                id: string;
              };
            };
            output: {};
            outputFormat: string;
            status: hono_utils_http_status20.StatusCode;
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
  admin: hono_client0.ClientRequest<string, "/admin", {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status20.StatusCode;
    };
  }>;
} & {
  admin: {
    ":uid": hono_client0.ClientRequest<string, "/admin/:uid", {
      $get: {
        input: {
          param: {
            uid: string;
          };
        };
        output: {};
        outputFormat: string;
        status: hono_utils_http_status20.StatusCode;
      };
    }>;
  };
} & {
  admin: {
    ":uid": {
      vacuum: hono_client0.ClientRequest<string, "/admin/:uid/vacuum", {
        $post: {
          input: {
            param: {
              uid: string;
            };
          };
          output: {};
          outputFormat: string;
          status: hono_utils_http_status20.StatusCode;
        };
      }>;
    };
  };
} & {
  admin: {
    ":uid": {
      "reset-import": hono_client0.ClientRequest<string, "/admin/:uid/reset-import", {
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
      delete: hono_client0.ClientRequest<string, "/admin/:uid/delete", {
        $get: {
          input: {
            param: {
              uid: string;
            };
          };
          output: {};
          outputFormat: string;
          status: hono_utils_http_status20.StatusCode;
        };
        $post: {
          input: {
            param: {
              uid: string;
            };
          };
          output: {};
          outputFormat: string;
          status: hono_utils_http_status20.StatusCode;
        };
      }>;
    };
  };
} & {
  admin: {
    ":uid": {
      ban: hono_client0.ClientRequest<string, "/admin/:uid/ban", {
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