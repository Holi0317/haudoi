# Self-hosting

This document outlines the steps and requirements to self-host Haudoi. Use this
scaffold to add detailed, environment-specific instructions (Cloudflare, CI,
backups, etc.).

## Overview

- What: Haudoi is a Cloudflare Worker-based link archiver and preview API with
  companion clients.
- Goal: run the Worker, the accompanying services, and the mobile/web clients in
  your environment.

## Prerequisites

- Node.js (v18+ recommended) and `pnpm`
- Cloudflare account and `wrangler` (for Workers deployment)
- Persistent storage: Cloudflare D1 / managed SQLite / external DB (Postgres)
  depending on scale
- DNS and domain for public access

## Architecture (high-level)

- `packages/worker`: Cloudflare Worker runtime, HTTP APIs, and background jobs
- `packages/dsl`: DSL parser and SQL generation used by search
- `mobile`: Flutter client that consumes the APIs

## Environment variables / secrets

- `CF_ACCOUNT_ID`, `CF_API_TOKEN`, `WRANGLER_ENV` — Cloudflare credentials
- `DATABASE_URL` or D1 identifiers
- `JWT_SECRET` (if used), `SENTRY_DSN` (optional)

Store secrets in Cloudflare environment bindings or CI secrets. Do not commit
them to the repo.

## Database setup & migrations

- If using Cloudflare D1: create database and run migrations via the Worker or a
  migration script.
- If using SQLite locally: ensure file-backed DB is present and migrations run
  before the Worker starts.
- Commands (example):

```bash
# run migrations (example command - replace with actual script)
pnpm --filter packages/worker run migrate
```

## Local development

- Install dependencies: `pnpm install`
- Start local Worker (example): `pnpm --filter packages/worker run dev`
- Start mobile client: open `mobile` and run `flutter run`

## Build & deploy (Cloudflare Workers)

- Configure `wrangler.toml` or `wrangler` config with account ID and
  environment.
- Example deploy command:

```bash
pnpm --filter packages/worker run build
pnpm --filter packages/worker run deploy
```

- For CI/CD, add Cloudflare API token to pipeline secrets and run the above
  commands in your workflow.

## Domain & TLS

- Point your domain to Cloudflare and enable proxying for TLS.
- Configure routes in `wrangler` or the Cloudflare dashboard to map your domain
  to the Worker.

## Backups & persistence

- If using D1, periodically export and back up tables to object storage.
- If using SQLite, schedule regular copies of the DB file to a safe location.

## Monitoring & logging

- Integrate Sentry or Cloudflare logs for errors and observability.
- Use Cloudflare Analytics and custom metrics as needed.

## Security

- Keep API tokens scoped and rotate regularly.
- Use Cloudflare Access and rate-limiting for public endpoints if needed.

## Troubleshooting

- Failed migrations: inspect migration logs and run migrations manually.
- Worker errors: check Cloudflare Workers logs and local `wrangler tail` for
  real-time logs.

## Useful links

- Cloudflare Workers: https://developers.cloudflare.com/workers/
- Wrangler (deploy): https://developers.cloudflare.com/workers/cli-wrangler/
- Cloudflare D1: https://developers.cloudflare.com/d1/

---

Add more environment-specific steps below (e.g., Docker Compose examples,
Kubernetes manifests, GitHub Actions examples, exact migration commands).
