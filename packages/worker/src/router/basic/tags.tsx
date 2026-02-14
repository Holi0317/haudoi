import { DateDisplay } from "../../component/DateDisplay";
import { ButtonLink } from "../../component/ButtonLink";
import { Layout } from "../../component/layout";
import { getUser } from "../../composable/user/getter";
import { zv } from "../../composable/validator";
import {
  IDStringSchema,
  TagCreateSchema,
  TagUpdateSchema,
} from "../../schemas";
import { factory } from "../factory";

export default factory
  .createApp()
  .get("/", async (c) => {
    const user = await getUser(c);
    const resp = await c.get("client").tag.$get();

    if (!resp.ok) {
      return c.json(await resp.json(), resp.status);
    }

    const { items } = await resp.json();

    return c.render(
      <Layout title="Tags">
        <a href="/basic">Back</a>
        <p>Authenticated via GitHub, {user.name}</p>

        <h2>Create tag</h2>
        <form
          method="post"
          action="/basic/tags"
          style={{ display: "flex", gap: "12px", flexWrap: "wrap" }}
        >
          <label style={{ display: "flex", flexDirection: "column" }}>
            Name
            <input name="name" maxLength={64} required={true} />
          </label>
          <label style={{ display: "flex", flexDirection: "column" }}>
            Color
            <input name="color" type="color" value="#64748b" />
          </label>
          <label style={{ display: "flex", flexDirection: "column" }}>
            Emoji
            <input name="emoji" />
          </label>
          <div>
            <input type="submit" value="Create" />
          </div>
        </form>

        <h2>Existing tags</h2>
        <p>Total tags = {items.length}</p>

        {items.length === 0 && <p>No tags yet.</p>}

        <ul>
          {items.map((tag) => (
            <li>
              <a href={`/basic/tags/${tag.id}`}>
                <strong>
                  {tag.emoji ? `${tag.emoji} ` : ""}
                  {tag.name}
                </strong>
                <span
                  style={{
                    display: "inline-block",
                    width: "12px",
                    height: "12px",
                    marginLeft: "8px",
                    border: "1px solid #333",
                    backgroundColor: tag.color,
                  }}
                  aria-label={`Tag color ${tag.color}`}
                />
              </a>
            </li>
          ))}
        </ul>
      </Layout>,
    );
  })
  .get("/:id", zv("param", IDStringSchema), async (c) => {
    const { id } = c.req.valid("param");
    const user = await getUser(c);
    const resp = await c.get("client").tag.$get();

    if (!resp.ok) {
      return c.json(await resp.json(), resp.status);
    }

    const { items } = await resp.json();
    const tag = items.find((item) => item.id === id);

    if (tag == null) {
      return c.text("not found", 404);
    }

    return c.render(
      <Layout title={`Tag - ${tag.name}`}>
        <a href="/basic/tags">Back</a>
        <p>Authenticated via GitHub, {user.name}</p>

        <h2>Edit tag</h2>
        <form
          method="post"
          action={`/basic/tags/${tag.id}`}
          style={{ display: "flex", gap: "12px", flexWrap: "wrap" }}
        >
          <label style={{ display: "flex", flexDirection: "column" }}>
            Name
            <input name="name" value={tag.name} maxLength={64} />
          </label>
          <label style={{ display: "flex", flexDirection: "column" }}>
            Color
            <input name="color" type="color" value={tag.color} />
          </label>
          <label style={{ display: "flex", flexDirection: "column" }}>
            Emoji
            <input name="emoji" value={tag.emoji} />
          </label>
          <div>
            <button type="submit">Update</button>
          </div>
        </form>

        <ButtonLink href={`/basic/tags/${tag.id}/delete`}>Delete</ButtonLink>

        <div>
          <small>
            Created at <DateDisplay timestamp={tag.created_at} />
          </small>
        </div>
      </Layout>,
    );
  })
  .post("/", zv("form", TagCreateSchema), async (c) => {
    const body = c.req.valid("form");

    const resp = await c.get("client").tag.$post({
      json: body,
    });

    if (!resp.ok) {
      return resp.clone() as never;
    }

    return c.redirect("/basic/tags");
  })
  .post(
    "/:id",
    zv("param", IDStringSchema),
    zv("form", TagUpdateSchema),
    async (c) => {
      const { id } = c.req.valid("param");
      const body = c.req.valid("form");

      const resp = await c.get("client").tag[":id"].$patch({
        param: {
          id: id.toString(),
        },
        json: body,
      });

      if (!resp.ok) {
        return c.json(await resp.json(), resp.status);
      }

      return c.redirect("/basic/tags");
    },
  )
  .get("/:id/delete", zv("param", IDStringSchema), async (c) => {
    const { id } = c.req.valid("param");
    const user = await getUser(c);
    const resp = await c.get("client").tag.$get();

    if (!resp.ok) {
      return c.json(await resp.json(), resp.status);
    }

    const { items } = await resp.json();
    const tag = items.find((item) => item.id === id);

    if (tag == null) {
      return c.text("not found", 404);
    }

    return c.render(
      <Layout title={`Delete tag - ${tag.name}`}>
        <a href={`/basic/tags/${tag.id}`}>Back</a>
        <p>Authenticated via GitHub, {user.name}</p>
        <h2>Delete tag</h2>
        <p>
          Are you sure you want to delete "{tag.name}"? This will remove the tag
          from all links.
        </p>
        <form method="post" action={`/basic/tags/${tag.id}/delete`}>
          <button type="submit">Yes, delete</button>
        </form>
      </Layout>,
    );
  })
  .post("/:id/delete", zv("param", IDStringSchema), async (c) => {
    const { id } = c.req.valid("param");

    const resp = await c.get("client").tag[":id"].$delete({
      param: {
        id: id.toString(),
      },
    });

    if (!resp.ok) {
      return resp.clone() as never;
    }

    return c.redirect("/basic/tags");
  });
