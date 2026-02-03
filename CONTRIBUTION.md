# SQL Guidelines

Storage is Durable object, with SQLite database available per user. Some brief
guideline for SQL (both DDL and DML).

- Use singular nouns for table name
- Use `integer` for primary key
  - This is vulnerable to int/number limit on JS/CloudFlare side.
    > Any numeric value in a column is affected by JavaScript's 52-bit precision
    > for numbers. If you store a very large number (in int64), then retrieve
    > the same value, the returned value may be less precise than your original
    > number.
    >
    > https://developers.cloudflare.com/durable-objects/api/storage-api/#returns
  - But each user got their own database instance so this is probably fine
- Timestamptz: Use `integer` unix epoch in millisecond to match what JS expects
  - Now is `unixepoch('now', 'subsec') * 1000`
  - Timezone is UTC, which is default for `unixepoch`
- text: Empty text and null must have distinct meaning. If there isn't any
  distinct meaning, throw `NOT NULL` and handle empty text differently
- Use following column types naming: `integer`, `text`, `blob`, `real`,
  `numberic`
- Boolean: `1` or `0`, remember add `CHECK`
  - SQLite driver will transform `true` and `false` (boolean js) into string in
    SQL layer. Use `Number(value)` to fix the value in SQL.
- Pagination: Use keyset pagination. Encode the cursor as base64.
  - Keys used is case-by-case. The only usecase currently is by create timestamp
    and id.
