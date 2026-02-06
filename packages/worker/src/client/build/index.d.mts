import * as hono_client0 from "hono/client";
import { ClientRequestOptions } from "hono/client";
import * as hono_utils_http_status17 from "hono/utils/http-status";
import * as hono_types1 from "hono/types";
import * as hono_hono_base0 from "hono/hono-base";

//#region src/router/index.d.ts
declare const app: hono_hono_base0.HonoBase<Env, hono_types1.BlankSchema | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status17.StatusCode;
    };
  };
}, "/"> | hono_types1.MergeSchemaPath<hono_types1.BlankSchema | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: "You have been successfully logged out!";
      outputFormat: "text";
      status: hono_utils_http_status17.ContentfulStatusCode;
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
      status: hono_utils_http_status17.ContentfulStatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.ContentfulStatusCode;
    };
  };
}, "/item"> | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {
        items: {
          [x: number]: {
            id: number;
            name: string;
            color: string;
            emoji: string;
            created_at: number;
          };
          length: number;
          toString: null;
          toLocaleString: null;
          pop: null;
          push: never;
          concat: never;
          join: never;
          reverse: null;
          shift: null;
          slice: never;
          sort: never;
          splice: never;
          unshift: never;
          indexOf: never;
          lastIndexOf: never;
          every: never;
          some: never;
          forEach: never;
          map: never;
          filter: never;
          reduce: never;
          reduceRight: never;
          find: never;
          findIndex: never;
          fill: never;
          copyWithin: never;
          entries: null;
          keys: null;
          values: null;
          includes: never;
          flatMap: never;
          flat: never;
          at: never;
          findLast: never;
          findLastIndex: never;
          toReversed: null;
          toSorted: never;
          toSpliced: never;
          with: never;
          [Symbol.iterator]: null;
          readonly [Symbol.unscopables]: {
            [x: number]: boolean | undefined;
            length?: boolean | undefined;
            toString?: boolean | undefined;
            toLocaleString?: boolean | undefined;
            pop?: boolean | undefined;
            push?: boolean | undefined;
            concat?: boolean | undefined;
            join?: boolean | undefined;
            reverse?: boolean | undefined;
            shift?: boolean | undefined;
            slice?: boolean | undefined;
            sort?: boolean | undefined;
            splice?: boolean | undefined;
            unshift?: boolean | undefined;
            indexOf?: boolean | undefined;
            lastIndexOf?: boolean | undefined;
            every?: boolean | undefined;
            some?: boolean | undefined;
            forEach?: boolean | undefined;
            map?: boolean | undefined;
            filter?: boolean | undefined;
            reduce?: boolean | undefined;
            reduceRight?: boolean | undefined;
            find?: boolean | undefined;
            findIndex?: boolean | undefined;
            fill?: boolean | undefined;
            copyWithin?: boolean | undefined;
            entries?: boolean | undefined;
            keys?: boolean | undefined;
            values?: boolean | undefined;
            includes?: boolean | undefined;
            flatMap?: boolean | undefined;
            flat?: boolean | undefined;
            at?: boolean | undefined;
            findLast?: boolean | undefined;
            findLastIndex?: boolean | undefined;
            toReversed?: boolean | undefined;
            toSorted?: boolean | undefined;
            toSpliced?: boolean | undefined;
            with?: boolean | undefined;
          };
          [Symbol.dispose]: null;
        };
      };
      outputFormat: "json";
      status: hono_utils_http_status17.ContentfulStatusCode;
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
      status: hono_utils_http_status17.ContentfulStatusCode;
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
          tags: {
            name: string;
            emoji: string;
            id: number;
            color: string;
          }[];
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
      status: hono_utils_http_status17.ContentfulStatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.ContentfulStatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
}, "/bulk">, "/basic"> | hono_types1.MergeSchemaPath<{
  "/": {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
      status: hono_utils_http_status17.StatusCode;
    };
  }>;
} & {
  auth: {
    logout: hono_client0.ClientRequest<string, "/auth/logout", {
      $get: {
        input: {};
        output: "You have been successfully logged out!";
        outputFormat: "text";
        status: hono_utils_http_status17.ContentfulStatusCode;
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
      status: hono_utils_http_status17.ContentfulStatusCode;
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
        status: hono_utils_http_status17.StatusCode;
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
          status: hono_utils_http_status17.ContentfulStatusCode;
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
            [x: number]: {
              id: number;
              name: string;
              color: string;
              emoji: string;
              created_at: number;
            };
            length: number;
            toString: null;
            toLocaleString: null;
            pop: null;
            push: never;
            concat: never;
            join: never;
            reverse: null;
            shift: null;
            slice: never;
            sort: never;
            splice: never;
            unshift: never;
            indexOf: never;
            lastIndexOf: never;
            every: never;
            some: never;
            forEach: never;
            map: never;
            filter: never;
            reduce: never;
            reduceRight: never;
            find: never;
            findIndex: never;
            fill: never;
            copyWithin: never;
            entries: null;
            keys: null;
            values: null;
            includes: never;
            flatMap: never;
            flat: never;
            at: never;
            findLast: never;
            findLastIndex: never;
            toReversed: null;
            toSorted: never;
            toSpliced: never;
            with: never;
            [Symbol.iterator]: null;
            readonly [Symbol.unscopables]: {
              [x: number]: boolean | undefined;
              length?: boolean | undefined;
              toString?: boolean | undefined;
              toLocaleString?: boolean | undefined;
              pop?: boolean | undefined;
              push?: boolean | undefined;
              concat?: boolean | undefined;
              join?: boolean | undefined;
              reverse?: boolean | undefined;
              shift?: boolean | undefined;
              slice?: boolean | undefined;
              sort?: boolean | undefined;
              splice?: boolean | undefined;
              unshift?: boolean | undefined;
              indexOf?: boolean | undefined;
              lastIndexOf?: boolean | undefined;
              every?: boolean | undefined;
              some?: boolean | undefined;
              forEach?: boolean | undefined;
              map?: boolean | undefined;
              filter?: boolean | undefined;
              reduce?: boolean | undefined;
              reduceRight?: boolean | undefined;
              find?: boolean | undefined;
              findIndex?: boolean | undefined;
              fill?: boolean | undefined;
              copyWithin?: boolean | undefined;
              entries?: boolean | undefined;
              keys?: boolean | undefined;
              values?: boolean | undefined;
              includes?: boolean | undefined;
              flatMap?: boolean | undefined;
              flat?: boolean | undefined;
              at?: boolean | undefined;
              findLast?: boolean | undefined;
              findLastIndex?: boolean | undefined;
              toReversed?: boolean | undefined;
              toSorted?: boolean | undefined;
              toSpliced?: boolean | undefined;
              with?: boolean | undefined;
            };
            [Symbol.dispose]: null;
          };
        };
        outputFormat: "json";
        status: hono_utils_http_status17.ContentfulStatusCode;
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
          status: hono_utils_http_status17.ContentfulStatusCode;
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
            tags: {
              name: string;
              emoji: string;
              id: number;
              color: string;
            }[];
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
        status: hono_utils_http_status17.ContentfulStatusCode;
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
          status: hono_utils_http_status17.StatusCode;
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
          status: hono_utils_http_status17.ContentfulStatusCode;
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
      status: hono_utils_http_status17.StatusCode;
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
          status: hono_utils_http_status17.StatusCode;
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
        status: hono_utils_http_status17.StatusCode;
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
  admin: hono_client0.ClientRequest<string, "/admin", {
    $get: {
      input: {};
      output: {};
      outputFormat: string;
      status: hono_utils_http_status17.StatusCode;
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
        status: hono_utils_http_status17.StatusCode;
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
          status: hono_utils_http_status17.StatusCode;
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
          status: hono_utils_http_status17.StatusCode;
        };
        $post: {
          input: {
            param: {
              uid: string;
            };
          };
          output: {};
          outputFormat: string;
          status: hono_utils_http_status17.StatusCode;
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