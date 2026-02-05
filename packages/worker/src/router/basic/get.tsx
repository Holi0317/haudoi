import { InsertForm } from "../../component/InsertForm";
import { Layout } from "../../component/layout";
import { LinkList } from "../../component/LinkList";
import { Pagination } from "../../component/Pagination";
import { SearchToolbar } from "../../component/SearchToolbar";
import { isAdmin } from "../../composable/user/admin";
import { getUser } from "../../composable/user/getter";
import { zv } from "../../composable/validator";
import { SearchQuerySchema } from "../../schemas";
import { factory } from "../factory";

export default factory.createHandlers(
  zv("query", SearchQuerySchema),
  async (c) => {
    const admin = await isAdmin(c);
    const user = await getUser(c);

    const queryRaw = c.req.queries();
    const qs = new URL(c.req.url).search;
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

        <InsertForm qs={qs} />

        <SearchToolbar query={query} />

        <p>Total count = {jason.count}</p>
        <LinkList items={jason.items} qs={qs} />

        <hr />

        <Pagination cursor={jason.cursor} queries={query} />
      </Layout>,
    );
  },
);
