---
name: dep-upgrade
description:
  Upgrade JavaScript/TypeScript dependencies in a pnpm monorepo. Use when user
  says "upgrade deps", "update dependencies", or "check for outdated packages".
  Triggered by dependabot groups or manual upgrade requests.
---

# Dependency Upgrade Workflow

## Overview

This skill defines a systematic workflow for upgrading JavaScript/TypeScript
dependencies in a pnpm monorepo. The workflow handles per-group changelog
research, fanout agents for parallel checking, codemod execution when needed,
and atomic commits between groups.

## When to Use

- User requests dependency upgrade ("upgrade deps", "update dependencies")
- Manual upgrade triggered by dependabot PRs or version check
- Periodic maintenance of JS/TS packages

## Workflow

### 1. Read Dependency Groups

First, read `.github/dependabot.yml` to understand how dependencies are grouped:

```bash
cat .github/dependabot.yml
```

Standard groups typically include:

- **linting**: eslint, prettier, typescript-eslint, husky, lint-staged,
  @stylistic/\*
- **wrangler**: wrangler, @cloudflare/\*
- **hono**: hono, @hono/\*, zod

Put ungrouped dependencies into their own commit. If the upgrade is major and
significant (involves multiple files change), move that dependency upgrade to
it's own commit.

### 2. Check Outdated Dependencies

```bash
pnpm outdated --recursive
```

Note current vs latest versions and which packages belong to which group.

### 3. Fanout Research Agents

For each group being upgraded, launch parallel explore agents to check
changelogs:

```
Research the changelog and release notes for <package> from version <current> to <latest>. Check npm or GitHub releases. Summarize any breaking changes, deprecations, or migration steps that would affect this codebase.
```

Run these in parallel using the `task` tool with `explore` subagent type.

### 4. Perform Upgrades

Upgrade each group with `pnpm up -r` for the relevant packages, specifying exact
versions from research.

#### Per-Group Commands

**Linting group:**

```bash
pnpm up -r eslint@<version> "@typescript-eslint/eslint-plugin@<version>" "@typescript-eslint/parser@<version>" prettier@<version> "lint-staged@<version>" globals@<version> "eslint-plugin-import-x@<version>" "eslint-plugin-vue@<version>"
```

**Wrangler group:**

```bash
pnpm up -r wrangler@<version> "@cloudflare/vitest-pool-workers@<version>" vitest@<version>
```

**Hono group:**

```bash
pnpm up -r hono@<version> zod@<version> "@hono/zod-validator@<version>"
```

**TypeScript (standalone):** Major version bumps should be separate commits.

```bash
pnpm up -r typescript@<version>
```

### 5. Handle Codemods When Required

Some upgrades require automated migration scripts (e.g., vitest v3→v4).

### 6. Run Verification

After each group upgrade, before committing:

```bash
pnpm lint
pnpm typecheck
pnpm test
```

Fix any issues before proceeding. Common issues:

- **Plugin type errors**: Check peer dependencies, might need to upgrade
  dependent packages (e.g., WXT for vite)
- **Test failures**: Verify Cloudflare vitest pool compatibility

### 7. Commit with Meaningful Message

```bash
git add -A && git commit -m "chore(deps): upgrade <group> group

- <pkg1> <old> → <new>
- <pkg2> <old> → <new>
..."
```

Commit each group separately so changes are atomic and reviewable.

## Special Cases

### Vitest + Cloudflare Compatibility

Before upgrading vitest in a worker project, verify
`@cloudflare/vitest-pool-workers` supports the new version:

```bash
pnpm show @cloudflare/vitest-pool-workers@<version> peerDependencies
```

The package requires minimum vitest version for v4 support. Check the research
findings for any breaking changes to test configuration.

### WXT / Extension Framework Compatibility

The WXT framework may lag behind vite minor versions. If `vue-tsc` fails with
plugin type errors after upgrading vite:

1. Check WXT's vite peer dependency requirement
2. Revert to compatible version if needed:
   `pnpm up -r vite@<compatible-version>`

### pnpm Version Upgrade

When upgrading pnpm itself:

1. Update `packageManager` field in `package.json`
2. The active shell may still use old pnpm via version managers (fnm, nvm) -
   note this for the user to restart their terminal

## File Locations

This skill lives in `.opencode/skills/dep-upgrade/SKILL.md` relative to the repo
root.

### Wrangler Types

After upgrading wrangler, regenerate types in `worker-configuration.d.ts` by
running:

```bash
pnpm run --filter @haudoi/worker cf-typegen
```

### Rolldown Client Types

After upgrading rolldown / hono / zod, and possibly more packages, regenerate
types in `client/build/index.d.mts` by running:

```bash
pnpm run --filter @haudoi/worker build-client
```

Just run this after finish upgrading all dependencies.
