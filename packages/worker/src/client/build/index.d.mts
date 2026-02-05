import * as hono_client0 from "hono/client";
import { ClientRequestOptions } from "hono/client";
import * as hono_utils_http_status15 from "hono/utils/http-status";
import * as hono_types1 from "hono/types";
import * as hono_hono_base0 from "hono/hono-base";

//#region src/router/index.d.ts
declare const app: hono_hono_base0.HonoBase<Env, hono_types1.BlankSchema | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status15.StatusCode;
    };
  };
}, "/"> | hono_types1.MergeSchemaPath<hono_types1.BlankSchema | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: "You have been successfully logged out!";
      outputFormat: "text";
      status: hono_utils_http_status15.ContentfulStatusCode;
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
      status: hono_utils_http_status15.ContentfulStatusCode;
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
      status: hono_utils_http_status15.StatusCode;
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
      status: hono_utils_http_status15.ContentfulStatusCode;
    };
  };
}, "/item"> | hono_types1.MergeSchemaPath<{
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
        }[];
        hasMore: boolean;
      };
      outputFormat: "json";
      status: hono_utils_http_status15.ContentfulStatusCode;
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
            field: "favorite" | "archive";
            value: boolean;
          } | {
            op: "set_string";
            id: number;
            field: "note";
            value: string;
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
      status: hono_utils_http_status15.StatusCode;
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
      status: hono_utils_http_status15.ContentfulStatusCode;
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
      status: hono_utils_http_status15.StatusCode;
    };
  };
} & {
  "/insert": {
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
} & {
  "/archive": {
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
} & {
  "/edit/:id": {
    $get: {
      input: {
        param: {
          id: string;
        };
      };
      output: {};
      outputFormat: string;
      status: hono_utils_http_status15.StatusCode;
    };
  };
} & {
  "/edit/:id": {
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
  "/edit/:id/delete": {
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
} & {
  "/bulk": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status15.StatusCode;
    };
  };
} & {
  "/bulk": {
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
}, "/basic"> | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status15.StatusCode;
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
      status: hono_utils_http_status15.StatusCode;
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
      status: hono_utils_http_status15.StatusCode;
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
      status: hono_utils_http_status15.StatusCode;
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
      status: hono_utils_http_status15.StatusCode;
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
          banned: "true" | "false";
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
          banned: "true" | "false";
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
      status: hono_utils_http_status15.StatusCode;
    };
  }>;
} & {
  auth: {
    logout: hono_client0.ClientRequest<string, "/auth/logout", {
      $get: {
        input: {};
        output: "You have been successfully logged out!";
        outputFormat: "text";
        status: hono_utils_http_status15.ContentfulStatusCode;
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
      status: hono_utils_http_status15.ContentfulStatusCode;
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
        status: hono_utils_http_status15.StatusCode;
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
          status: hono_utils_http_status15.ContentfulStatusCode;
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
          }[];
          hasMore: boolean;
        };
        outputFormat: "json";
        status: hono_utils_http_status15.ContentfulStatusCode;
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
              field: "favorite" | "archive";
              value: boolean;
            } | {
              op: "set_string";
              id: number;
              field: "note";
              value: string;
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
          status: hono_utils_http_status15.StatusCode;
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
          status: hono_utils_http_status15.ContentfulStatusCode;
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
      status: hono_utils_http_status15.StatusCode;
    };
  }>;
} & {
  basic: {
    bulk: hono_client0.ClientRequest<string, "/basic/bulk", {
      $get: {
        input: {};
        output: {};
        outputFormat: string;
        status: hono_utils_http_status15.StatusCode;
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
          status: hono_utils_http_status15.StatusCode;
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
  admin: hono_client0.ClientRequest<string, "/admin", {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status15.StatusCode;
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
        status: hono_utils_http_status15.StatusCode;
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
          status: hono_utils_http_status15.StatusCode;
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
          status: hono_utils_http_status15.StatusCode;
        };
        $post: {
          input: {
            param: {
              uid: string;
            };
          };
          output: {};
          outputFormat: string;
          status: hono_utils_http_status15.StatusCode;
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
              banned: "true" | "false";
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
              banned: "true" | "false";
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