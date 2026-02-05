import type { LinkItem } from "../schemas";
import { ButtonLink } from "./ButtonLink";

export interface LinkItemProps {
  item: LinkItem;

  /**
   * Query string for the route/page, with leading `?`
   *
   * For restoring query after edit.
   */
  qs: string;
}

export function LinkItem(props: LinkItemProps) {
  const { item, qs } = props;

  const title = item.title || item.url;

  return (
    <li>
      <div style={{ display: "inline-flex", alignItems: "baseline" }}>
        <a
          href={item.url}
          target="_blank"
          rel="noopener noreferrer"
          alt={title}
        >
          {title}
        </a>

        <form
          action="/basic/archive"
          method="post"
          style={{ margin: 0, marginLeft: 8 }}
        >
          <input type="hidden" name="id" value={item.id} />
          <input type="hidden" name="qs" value={qs} />

          <input type="submit" value="archive" />
        </form>

        <ButtonLink href={`/basic/edit/${item.id}`}>Edit</ButtonLink>
      </div>
    </li>
  );
}
