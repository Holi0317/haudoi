# AGENTS.md

## Project Structure

Monorepo with pnpm workspaces:

- `packages/worker` - Cloudflare Worker backend (Hono, Durable Objects with
  SQLite)
- `packages/dsl` - Shared DSL for schema/builder logic
- `packages/extension` - Browser extension (Vue 3, WXT)
- `mobile/` - Flutter app (Riverpod, Freezed, go_router)

## Developer Commands

**Root (run from repo root):**

```bash
pnpm install              # Install all deps (runs husky install)
pnpm dev                  # Start worker dev server
pnpm lint                 # ESLint all packages
pnpm fmt                  # Prettier format
pnpm typecheck            # Type check all packages
pnpm test                 # Run all tests
```

**Worker package:**

```bash
pnpm run --filter @haudoi/worker dev          # wrangler dev
pnpm run --filter @haudoi/worker deploy       # wrangler deploy --minify
pnpm run --filter @haudoi/worker cf-typegen   # Generate CloudflareBindings types
pnpm run --filter @haudoi/worker build-client # Build client SDK to src/client/build/
```

**Extension package:**

```bash
pnpm run --filter @haudoi/extension dev           # wxt dev (Chrome)
pnpm run --filter @haudoi/extension dev:firefox   # wxt dev (Firefox)
pnpm run --filter @haudoi/extension build         # Build extension
pnpm run --filter @haudoi/extension zip           # Build zip for submission
```

**Mobile (run from `mobile/` directory):**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # Regenerate freezed/json_serializable
flutter run
```

## CI Order (lint.yml)

1. `pnpm install --frozen-lockfile`
2. `pnpm run --filter @haudoi/worker cf-typegen`
3. `pnpm run --filter @haudoi/worker build-client`
4. `pnpm lint`
5. `pnpm fmt --check`
6. `pnpm typecheck`
7. `pnpm test`

CI fails if `cf-typegen` or `build-client` produce uncommitted changes.

## Architecture Notes

**Worker:**

- Entry: `packages/worker/src/index.ts`
- Uses Durable Objects with per-user SQLite databases
- Client SDK exported at `@haudoi/worker/client` (built to `src/client/build/`)
- Cloudflare types generated to `worker-configuration.d.ts` - **must be
  committed**

**DSL:**

- Pure TypeScript, no build step
- Exports from `src/index.ts`

**Extension:**

- Built with WXT framework
- Vue 3 + PrimeVue + TanStack Query
- Imports `@haudoi/worker` directly via workspace link

**Mobile:**

- Riverpod for state management
- Freezed for immutable models and union types
- go_router for navigation
- slang for i18n (`.i18n.yaml` files in `lib/i18n/`)
- Generated files: `*.g.dart`, `*.freezed.dart` - **must be committed**

## Conventions & Quirks

**TypeScript:**

- ES modules, `"moduleResolution": "Bundler"`
- Explicit `.ts`/`.tsx` extensions in imports where needed
- `@typescript-eslint/no-unused-vars` allows `^_` prefix

**SQL (Durable Objects):**

- See `CONTRIBUTION.md` for full guidelines
- Table names: singular
- Timestamps: `integer` unix epoch (ms)
- Booleans: `1`/`0` with `CHECK` constraint
- Pagination: keyset, base64-encoded cursors

**Dart/Flutter:**

- Use Dart 3 pattern matching (`switch` expressions) over Freezed
  `.when()`/`.map()`
- Riverpod `AsyncValue`: prefer `switch` over `.when()`
- JSON: typed Freezed models with `fromJson`/`toJson`, no inline parsing
- Generated files must be regenerated and committed after model changes
- Never edit `*.g.dart` or `*.freezed.dart` manually; change source files only
- Keep JSON parsing at model boundary; work with typed objects elsewhere

**Formatting:**

- Prettier: `proseWrap: "always"`
- ESLint: `curly: ["error", "all"]`
- 2-space tabs (VSCode settings)

## Prerequisites

- Node.js 24 (see `.node-version`)
- pnpm 10.31.0 (packageManager field)
- Flutter 3.41.4, Dart 3.10.0 (see `mobile/pubspec.yaml`)
- Cloudflare Workers environment for deployment
