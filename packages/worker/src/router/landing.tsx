import { factory } from "./factory";
import { getSession } from "../composable/session/getter";

const app = factory.createApp().get("/", async (c) => {
  const sess = await getSession(c, false);

  const url = new URL("/", c.req.url);

  return c.render(
    <>
      <p>Hi, welcome to haudoi (口袋), a link collection service.</p>

      <p>
        <a
          href="https://github.com/Holi0317/haudoi"
          rel="noopener noreferrer"
          target="_blank"
        >
          Why this looks so unstyled and ugly
        </a>
      </p>

      <p>
        <a href="/basic">{sess == null ? "Login to web" : "Go to web"}</a>
      </p>

      <p>
        This API endpoint is at <code>{url.toString()}</code> Mobile app or
        extension will ask for this URL.
      </p>
    </>,
  );
});

export default app;
