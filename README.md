# Haudoi

Haudoi is a personal link archiving and preview service implemented as a
Cloudflare Worker and companion web/mobile clients. It stores, indexes, and
previews links (favicons, titles, images) and provides search and image-preview
APIs for downstream clients.

**How to access:**

- **App URL (placeholder):** https://example.haudoi.local

**Self-hosting:**

See [here](./docs/hosting.md)

**Repository layout (high-level):**

- **`packages/worker`**: Cloudflare Worker runtime and API handlers.
- **`packages/dsl`**: DSL parser and SQL generation utilities used by search.
- **`mobile`**: Flutter mobile app that consumes the APIs.

## Query DSL

Link search is done through DSL (domain specific language). This language is
similar to GitHub's issue and PR search, or lucene search syntax.

The query DSL is implemented in [@haudoi/dsl](./packages/dsl) package.

### Syntax rules

- `field:value` for specifying field match.
- Each fields have a configured type associated:
  - Boolean fields accept `true` or `false` (case insensitive)
  - String fields are searched through case insensitive substring match
- Value can be string without space, or quoted with `"`, `'` or backtick
- Spaces outside quotes treated as AND combination
- Complexity limit of 5 matchers. Exceeding this throws an error.

### Fields

- `favorite`: Boolean field
- `archive`: Boolean field
- `url`: String field
- `note`: String field
- `note`: String field
