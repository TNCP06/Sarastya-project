# Sarastya Drive — umbrella/infra repo — agent guide

This repo is the **infrastructure + Python Telegram engine** tier of a 4-repo system. Files are
stored as messages in a private Telegram channel; a **self-hosted PostgreSQL** database
(`scd-postgres`) holds metadata; a **.NET 8 API** (`Sarastya-project-api`) is the JWT/REST/metadata
layer; a **Next.js web** (`Sarastya-project-web`) and **Flutter mobile** (`Sarastya-project-mobile`)
are the clients. Everything coordinates **only through Postgres**. Branch for this product:
**`feat/cloud-drive`** in every repo.

This repo holds: `bot/` (the Python engine), `bot/schema.sql` (the schema — single source of
truth), `docker-compose.yml` (the whole `scd` stack), `.env.example`, `deploy.sh`. See
[`PLAN.md`](PLAN.md) for the cross-agent task breakdown and the master plan at the workspace root
(`SARASTYA-MIGRATION.md`, local-only).

## The Python engine (in `bot/`)

`bot.py` (index + download + purge + Bot Drop + daily DB backup), `watcher.py` (upload-queue
executor), `streamer.py` (video streaming + background compression). They talk *only* through
Postgres tables. **Keep the modular split** — don't re-monolith:

- `bot_config.py` (env/logging + `DATABASE_URL`), `pg_db.py` (Postgres client shim), `tg_helpers.py`
  (pure helpers), `db_ops.py` (Postgres ops), `indexing.py` (channel indexing + thumbnail harvest +
  `index_bot_copy`), `db_backup.py` (daily `pg_dump` → Telegram), and `bot.py` (interactive handlers
  + `main()`). `bot.py` **re-exports** the names `index_history.py` imports via `from bot import …` —
  keep that surface intact. `streamer.py`'s background compression is in `stream_compress.py`;
  subtitle generation in `stream_subtitles.py`.

**DB access is via a thin compat shim** so SQL call sites keep `?` placeholders: `bot/pg_db.py`
wraps `psycopg` (rewrites `?`→`%s`). SQL is Postgres dialect: `now_text()` (UTC-text helper),
`ON CONFLICT … DO UPDATE/NOTHING`, `lower(x)` for case-insensitive matches. Don't reintroduce
SQLite-isms.

## Load-bearing invariants (don't break)

- **Caption contract** `Title | part/total | tag1, tag2` drives auto-indexing.
- **`items.slug` is immutable** — multi-part grouping key + download deep-link target.
- **`parts.channel_msg_id` is UNIQUE** — re-index idempotency key + `copy_message` download target.
- **Soft delete** sets `items.deleted_at`; bot hard-deletes from Telegram only after >7 days.
- **`users` table is auth-only** — the drive is single-tenant (no `user_id` on folders/items); the
  .NET API maps EF entities to it and runs **no prod migrations**. `schema.sql` here owns it.

## scd stack isolation (must NOT collide with the existing `tcd` stack)

Same VPS hosts both. This stack uses `scd-*` container/service names, the `scd-net` network, DB
`scd`, `COMPOSE_PROJECT_NAME=scd`, and shifted host ports (web 3100 · api 8090@localhost ·
streamer 8088 · tg-bot-api 8181@localhost · postgres 5433@localhost). Deploy folder is `~/scd`;
**never touch `~/tcd`**. NEW Telegram bot token + storage channel (see local secrets file).

`docker-compose.yml` builds api/web from **sibling repos** (`../Sarastya-project-api`,
`../Sarastya-project-web`) and the Python engine from local `./bot`; all four repos are cloned
side-by-side under `~/scd`.

## Verify before committing

- Python: `python -m py_compile bot/*.py`.
- Compose: `docker compose config -q` (needs POSTGRES_PASSWORD/JWT_SECRET/DATABASE_URL set).
- Keep `bot/schema.sql` in sync with `Sarastya-project-api/db/users.sql` for the `users` table.

**Commit messages**: Conventional-Commits subject (`type(scope): summary`, imperative, ≤~72 chars),
blank line, then `- …` bullets (one concrete change each). No trailing sign-off line.

## VPS

SSH: `ssh -i "C:\Users\TNCP\Downloads\sarastya.pem" ec2-user@13.251.1.78`. After any VPS testing,
leave the repo clean for CD: `git reset --hard HEAD && git clean -fd`. Existing stack `~/tcd` is
off-limits.
