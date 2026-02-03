import type { SearchQueryType } from "../schemas";

export interface SearchToolbarProps {
  query: SearchQueryType;
}

export function SearchToolbar(props: SearchToolbarProps) {
  const { query } = props;

  return (
    <form>
      <input
        type="text"
        name="query"
        value={query.query}
        placeholder="Search DSL"
      />

      <a
        href="https://github.com/Holi0317/haudoi?tab=readme-ov-file#query-dsl"
        target="_blank"
        rel="noopener noreferrer"
        style={{ margin: "0 8px" }}
      >
        Search DSL docs
      </a>

      <select name="order">
        <option
          value="created_at_asc"
          selected={query.order === "created_at_asc"}
        >
          Ascending (oldest first)
        </option>
        <option
          value="created_at_desc"
          selected={query.order === "created_at_desc"}
        >
          Descending (newest first)
        </option>
      </select>

      <input type="submit" />
    </form>
  );
}
