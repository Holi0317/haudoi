import { factory } from "./factory";
import * as z from "zod";
import { requireSession } from "../composable/session/middleware";
import type { EditOpSchema } from "../schemas";
import { IDStringSchema, SearchQuerySchema } from "../schemas";
import { zv } from "../composable/validator";
import { Layout } from "../component/layout";
import { Pagination } from "../component/Pagination";
import { LinkItemForm } from "../component/LinkItemForm";
import * as zu from "../zod-utils";
import { InsertForm } from "../component/InsertForm";
import { LinkList } from "../component/LinkList";
import { SearchToolbar } from "../component/SearchToolbar";
import { getUser } from "../composable/user/getter";
import { isAdmin } from "../composable/user/admin";
import { ImportStatus } from "../component/ImportStatus";
import { ImportForm } from "../component/ImportForm";

const ItemEditSchema = z.object({
  // FIXME: <input type="checkbox"> won't send anything if unchecked.
  archive: zu.queryBool(),
  favorite: zu.queryBool(),
  note: z.string().max(4096).optional(),
});

/**
 * Basic views for the app
 */
const app = factory
  .createApp()
  .use(requireSession({ action: "redirect", destination: "/basic" }))

  .get("/", zv("query", SearchQuerySchema), async (c) => {
    const admin = await isAdmin(c);
    const user = await getUser(c);

    const queryRaw = c.req.queries();
    const query = c.req.valid("query");

    // Assume empty query means someone opens this page for the first time.
    // We wanna show unarchived items if that's the case.
    if (Object.keys(queryRaw).length === 0) {
      return c.redirect("?query=archive:false");
    }

    const resp = await c.get("client").search.$get({
      query: queryRaw,
    });

    const jason = await resp.json();

    // Handle DSL parsing errors
    if (resp.status === 400) {
      const errorBody = jason as unknown as { message: string };
      return c.render(
        <Layout title="Search Error">
          <p>Authenticated via GitHub, {user.name}</p>
          <div
            style={{ color: "red", padding: "10px", border: "1px solid red" }}
          >
            <strong>Search Error:</strong> {errorBody.message}
          </div>
          <SearchToolbar query={query} />
          <a href="/basic">Back to all items</a>
        </Layout>,
      );
    }

    return c.render(
      <Layout title="List">
        <p>Authenticated via GitHub, {user.name}</p>

        {admin && (
          <div>
            <a href="/admin">Admin console</a>
          </div>
        )}

        <div>
          <a href="/basic/bulk">Import / Export</a>
        </div>

        <InsertForm />

        <SearchToolbar query={query} />

        <p>Total count = {jason.count}</p>
        <LinkList items={jason.items} />

        <hr />

        <Pagination cursor={jason.cursor} queries={query} />
      </Layout>,
    );
  })
  .post("/insert", zv("form", z.object({ url: z.string() })), async (c) => {
    const { url } = c.req.valid("form");

    const resp = await c.get("client").edit.$post({
      json: {
        op: [{ op: "insert", url }],
      },
    });

    if (resp.status >= 400) {
      return c.json(await resp.json(), resp.status);
    }

    return c.redirect("/basic?archive=false");
  })

  .post("/archive", zv("form", IDStringSchema), async (c) => {
    const { id } = c.req.valid("form");

    await c.get("client").edit.$post({
      json: {
        op: [{ op: "set_bool", field: "archive", id, value: true }],
      },
    });

    return c.redirect("/basic?archive=false");
  })

  .get("/edit/:id", zv("param", IDStringSchema), async (c) => {
    const { id } = c.req.valid("param");

    const resp = await c.get("client").item[":id"].$get({
      param: {
        id: id.toString(),
      },
    });

    if (resp.status === 404) {
      return c.text("not found", 404);
    }

    const jason = await resp.json();

    return c.render(
      <Layout title="Edit">
        <a href="/basic">Back</a>
        <LinkItemForm item={jason} />

        <form method="post" action={`/basic/edit/${id}/delete`}>
          <input type="submit" value="Delete" />
        </form>
      </Layout>,
    );
  })

  .post(
    "/edit/:id",
    zv("param", IDStringSchema),
    zv("form", ItemEditSchema),
    async (c) => {
      const { id } = c.req.valid("param");
      const form = c.req.valid("form");

      const op: Array<z.input<typeof EditOpSchema>> = [];

      if (form.archive != null) {
        op.push({
          op: "set_bool",
          field: "archive",
          id,
          value: form.archive,
        });
      }

      if (form.favorite != null) {
        op.push({
          op: "set_bool",
          field: "favorite",
          id,
          value: form.favorite,
        });
      }

      if (form.note != null) {
        op.push({
          op: "set_string",
          field: "note",
          id,
          value: form.note,
        });
      }

      await c.get("client").edit.$post({
        json: {
          op,
        },
      });

      return c.redirect(`/basic/edit/${id}`);
    },
  )

  .post("/edit/:id/delete", zv("param", IDStringSchema), async (c) => {
    const { id } = c.req.valid("param");

    await c.get("client").edit.$post({
      json: {
        op: [{ op: "delete", id }],
      },
    });

    return c.redirect(`/basic`);
  })

  .get("/bulk", async (c) => {
    const { status } = await c
      .get("client")
      .bulk.import.$get()
      .then((r) => r.json());

    return c.render(
      <Layout title="Import / Export">
        <a href="/basic">Back</a>
        <h2>Import</h2>

        <ImportStatus status={status} />
        {(status == null || status.completed != null) && <ImportForm />}

        <h2>Export</h2>
        <form method="post" action="/api/bulk/export">
          <input type="submit" value="Export CSV" />
        </form>
      </Layout>,
    );
  })
  .post(
    "/bulk",
    zv(
      "form",
      z.object({
        // `z.file()` is broken. zod relies on globalThis.File which isn't available or inferrable
        // in this typescript environment.
        // Using instanceof check as a workaround.
        file: z.instanceof(File),
      }),
    ),
    async (c) => {
      const client = c.get("client");
      const { file } = c.req.valid("form");

      const resp = await client.bulk.import.$post({
        form: {
          file,
        },
      });

      if (!resp.ok) {
        return c.json(await resp.json(), resp.status);
      }

      return c.redirect("/basic/bulk");
    },
  );

export default app;
