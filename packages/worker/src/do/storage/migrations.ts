import { sql } from "../../composable/sql";
import type { DBMigration } from "../../composable/db_migration";

export const migrations: DBMigration[] = [
  {
    name: "20250610-create-link",
    script: sql`
CREATE TABLE link (
  -- ID/PK of the link. This is a tie breaker for links with same created_at timestamp.
  -- On conflict of URL, we will replace (delete and insert) the row and bump ID.
  id integer PRIMARY KEY AUTOINCREMENT,

  -- Title of the link's HTML page.
  -- If title wasn't available, this will empty string.
  -- WARNING: Title can be used for XSS. Remember to escape before rendering
  title text NOT NULL CHECK (length(title) < 512),
  -- URL of the link.
  url text NOT NULL UNIQUE
    CHECK (url like 'http://%' OR url like 'https://%')
    CHECK (length(url) < 512),
  -- Boolean. Favorite or not.
  favorite integer NOT NULL
    CHECK (favorite = 0 OR favorite = 1)
    DEFAULT FALSE,
  -- Boolean. Archived or not.
  archive integer NOT NULL
    CHECK (archive = 0 OR archive = 1)
    DEFAULT FALSE,
  -- Insert timestamp in epoch milliseconds.
  created_at integer NOT NULL DEFAULT (unixepoch('now', 'subsec') * 1000)
);

CREATE INDEX idx_link_favorite ON link(favorite);
CREATE INDEX idx_link_archive ON link(archive);
`,
  },
  {
    name: "20250612-add-note-column",
    script: sql`
ALTER TABLE link ADD COLUMN note text NOT NULL DEFAULT '' CHECK (length(note) <= 4096);
`,
  },
  {
    name: "20251218-idx-created-at",
    script: sql`
CREATE INDEX idx_link_created_at_sort ON link(created_at DESC, id DESC);
`,
  },
];
