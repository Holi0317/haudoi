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
  {
    name: "20260205-add-tags",
    script: sql`
CREATE TABLE tag (
  id integer PRIMARY KEY AUTOINCREMENT,
  -- Tag name, stored in original case but unique when compared case-insensitively
  name text NOT NULL CHECK (length(name) > 0 AND length(name) <= 64),
  -- Tag color as hex string (e.g., #FF5733). Validation done at application layer.
  color text NOT NULL CHECK (length(color) = 7 AND color GLOB '#*'),
  -- Optional emoji for the tag. Default to empty string if not provided.
  emoji text NOT NULL CHECK (length(emoji) <= 8) DEFAULT '',
  created_at integer NOT NULL DEFAULT (unixepoch('now', 'subsec') * 1000)
);

-- Case-insensitive unique index on tag name
CREATE UNIQUE INDEX idx_tag_name_lower ON tag(lower(name));

-- Junction table: links tags to links by numeric id
CREATE TABLE link_tag (
  link_id integer NOT NULL REFERENCES link(id) ON DELETE CASCADE,
  tag_id integer NOT NULL REFERENCES tag(id) ON DELETE CASCADE,
  PRIMARY KEY (link_id, tag_id)
);

-- Index for efficient lookup of links by tag
CREATE INDEX idx_link_tag_tag_id ON link_tag(tag_id);
`,
  },
];
