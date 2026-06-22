# Sarastya Drive

A **Telegram-backed cloud drive**: files are stored as messages in a private Telegram channel, a
self-hosted PostgreSQL database holds the metadata, and a 3-tier app (REST API + web + mobile)
provides auth and the drive UI. Built for the Sarastya technical-test brief
(.NET 8 REST backend + React/Next.js web + Flutter mobile, JWT auth, Swagger, ≥2 related entities
with CRUD, responsive web, installable APK).

This repo (**`Sarastya-project`**) is the **umbrella / infrastructure** repo: it holds the Python
Telegram engine, the database `schema.sql`, the `docker-compose.yml` that wires the whole stack,
and the deploy tooling. The other three tiers live in their own repos.

## Repositories

| Repo | Tier | What it is |
|---|---|---|
| **Sarastya-project** (this) | Infra + engine | Python Telegram engine, `schema.sql`, compose, deploy |
| [Sarastya-project-api](https://github.com/TNCP06/Sarastya-project-api) | Backend | .NET 8 REST API — JWT auth + metadata CRUD (Dapper read / EF write), Swagger |
| [Sarastya-project-web](https://github.com/TNCP06/Sarastya-project-web) | Web | Next.js dashboard — Fetch + JWT to the API |
| [Sarastya-project-mobile](https://github.com/TNCP06/Sarastya-project-mobile) | Mobile | Flutter client — APK |

> New work for this product lives on the **`feat/cloud-drive`** branch in every repo; `main` keeps
> the previous submission.

## Architecture

```
 drive.tncp.web.id ──► scd-web (Next.js)  ──Fetch + JWT──►  scd-api (.NET 8, internal only)
 stream.tncp.web.id ─► scd-streamer (Python video)              │  JWT auth + metadata CRUD
 Flutter APK ───────► drive.tncp.web.id/papi/* ─► scd-api       ▼
        scd-bot / scd-watcher (Python, Telegram I/O) ──►  PostgreSQL (scd-postgres)  ◄── api / web
```

- **scd-api** — the REST/JWT/metadata layer over Postgres for web + mobile. Entities: `User`,
  `Folder` (1─N) `Item` (1─N) `Part`, and `Item` (N─N) `Tag`. Reads = Dapper, writes = EF Core.
- **Python engine stays** — Telethon MTProto uploads, on-the-fly streaming, ffmpeg compression,
  Whisper subtitles. It talks to the rest only through Postgres.
- **Web** uses Fetch + JWT for auth and all CRUD; binary-heavy routes (`/api/stream`, `/api/thumb`,
  `/api/subtitles`, `/api/events`) stay as Next routes proxying the streamer / reading Postgres.
- **API is internal-only**, reachable publicly only via the web's `/papi/*` rewrite — so mobile
  uses the drive domain too. No extra DNS.

The drive is **single-tenant**: there is no `user_id` on folders/items; the `users` table is
auth-only and JWT gates access. `space=main|private` partitions the views.

## Deploy (VPS, under `~/scd`)

This stack is isolated from the existing `tcd` stack on the same box: `scd-*` container names, the
`scd-net` network, DB `scd`, and shifted host ports (web `3100`, api `8090`@localhost,
streamer `8088`, tg-bot-api `8181`@localhost, postgres `5433`@localhost).

```bash
# On the VPS, clone all four repos side-by-side under ~/scd (feat/cloud-drive branch):
cd ~/scd && cp Sarastya-project/.env.example Sarastya-project/.env
#   edit .env: POSTGRES_PASSWORD, JWT_SECRET, NEW bot token/channel,
#   copy TG_API_ID/HASH + GROQ_API_KEYS from ~/tcd/.env
#   create bot/worker.session + bot/streamer.session (Telethon login once)
cd Sarastya-project && ./deploy.sh
```

`scd-postgres` applies [`bot/schema.sql`](bot/schema.sql) automatically on first init.
Public HTTPS is provided by a Cloudflare Tunnel (`scd-cloudflared`): point
`drive.tncp.web.id → http://scd-web:3000` and `stream.tncp.web.id → http://scd-streamer:8080`.

## Repo layout

- `bot/` — Python Telegram engine (modular): `bot.py`, `watcher.py`, `streamer.py`
  (+`stream_compress.py`, `stream_subtitles.py`), `index_history.py`, and helpers
  (`db_ops.py`, `indexing.py`, `tg_helpers.py`, `pg_db.py`, `bot_config.py`, `db_backup.py`).
- `bot/schema.sql` — single source of truth for the Postgres schema (incl. the `users` table).
- `docker-compose.yml` — the full scd stack. `.env.example` — all required env. `deploy.sh` — deploy.
