# AGENTS.md

## Project Structure

Monorepo with pnpm workspaces:

- `packages/worker` - Cloudflare Worker backend (Hono, Durable Objects withSQLite)
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

**Mobile (run from **`mobile/`** directory):**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # Regenerate freezed/json_serializable
flutter run
```

> If you haven't set up the mise shell hook, prefix commands with `mise exec --`
> (e.g. `mise exec -- flutter pub get`). With the shell hook active, commands
> run transparently with the correct tool versions.

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
- Cloudflare types generated to `worker-configuration.d.ts` - **must becommitted**

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

- Use Dart 3 pattern matching (`switch` expressions) over Freezed`.when()`/`.map()`
- Riverpod `AsyncValue`: prefer `switch` over `.when()`
- JSON: typed Freezed models with `fromJson`/`toJson`, no inline parsing
- Generated files must be regenerated and committed after model changes
- Never edit `*.g.dart` or `*.freezed.dart` manually; change source files only
- Keep JSON parsing at model boundary; work with typed objects elsewhere
- i18n: hard-code strings during development; move to `.i18n.yaml` when asked
- Translation scope: per-page or per-component (duplicates expected)
- **Never remove comments from existing code** unless explicitly asked torefactor

**Formatting:**

- Prettier: `proseWrap: "always"`
- ESLint: `curly: ["error", "all"]`
- 2-space tabs (VSCode settings)

## Prerequisites

- [mise](https://mise.jdx.dev) - tool version manager for all project runtimes
  - Run `mise install` after cloning to install Node.js, pnpm, Flutter, and Dart
  - Use `mise exec -- <command>` to run project commands, or set up the shell hook
    for transparent version switching (`mise activate` in your shell config, then
    `mise trust` in the repo)
  - Tool versions are managed in `mise.toml` — no separate `.node-version` or
    manual Flutter/Dart installs needed
- Cloudflare Workers environment for deployment