import type { LinkItemWithTags, TagItem } from "../schemas";
import { DateDisplay } from "./DateDisplay";

export interface LinkItemFormProps {
  item: LinkItemWithTags;
  tags: TagItem[];
}

export function LinkItemForm(props: LinkItemFormProps) {
  const { item, tags } = props;
  const appliedTagIds = new Set(item.tags?.map((tag) => tag.id) ?? []);

  return (
    <form method="post">
      <div>
        <label>
          ID
          <input name="id" disabled={true} value={item.id} />
        </label>
      </div>

      <div>
        <label>
          Title
          <input name="title" disabled={true} value={item.title} />
        </label>
      </div>

      <div>
        <label>
          URL
          <input name="url" disabled={true} value={item.url} />
        </label>
      </div>

      <div>
        <label>
          Archive
          <input name="archive" type="checkbox" checked={item.archive} />
        </label>
      </div>

      <div>
        <label>
          Favorite
          <input name="favorite" type="checkbox" checked={item.favorite} />
        </label>
      </div>

      <div>
        <label>
          Note
          <textarea name="note" maxLength={4096}>
            {item.note}
          </textarea>
        </label>
      </div>

      <div>
        <label>
          Tags
          <select name="tags" multiple={true}>
            {tags.map((tag) => (
              <option
                key={tag.id}
                value={tag.id}
                selected={appliedTagIds.has(tag.id)}
              >
                {tag.emoji}

                {tag.name}
              </option>
            ))}
          </select>
        </label>
      </div>

      <div>
        <label>
          Created at <DateDisplay timestamp={item.created_at} />
        </label>
      </div>

      <input type="submit" value="submit" />
    </form>
  );
}
