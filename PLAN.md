# Sarastya Cloud Drive — Umbrella / Infra repo plan

> This repo (`Sarastya-project`) is the **deploy/orchestration + Python Telegram engine** repo for
> **Sarastya Drive**, a Telegram-backed cloud drive. It is part of a 4-repo system rebuilt from a
> Telegram Cloud Drive under the Sarastya technical-test brief (`.NET API + React web + Flutter`).
> Work happens on branch **`feat/cloud-drive`**; `main` keeps the old ProjekTask landing page.
>
> **This is the cross-agent source of truth** — no agent-specific memory is used. Status: ☐ todo · ◐ wip · ☑ done

## System overview (all 4 repos)

```
 drive.tncp.web.id ─► web (Next.js :3000) ──Fetch+JWT──► api (.NET :8080, internal)
 stream.tncp.web.id ─► streamer (:8080, Python)                 │
 Flutter APK ─► drive.tncp.web.id/papi/* ─► api                 ▼
        bot + watcher (Python, Telegram I/O) ──► PostgreSQL ◄── api / web
```
- **api** = `Sarastya-project-api` (.NET 8: JWT auth + metadata CRUD; Dapper read / EF write).
- **web** = `Sarastya-project-web` (adapt the rich Next.js drive dashboard; Fetch+JWT).
- **mobile** = `Sarastya-project-mobile` (Flutter focused client).
- **this repo** = Python engine + `docker-compose.yml` + `schema.sql` + `.env.example` + deploy.

## Role of THIS repo

1. **Python Telegram engine** (ported from the source Cloud Drive `bot/`): `bot.py` (index /
   download / purge / daily DB backup / Bot Drop), `watcher.py` (upload-queue executor),
   `streamer.py` (+`stream_compress.py`, `stream_subtitles.py`), `index_history.py`, helpers
   (`db_ops.py`, `indexing.py`, `tg_helpers.py`, `pg_db.py`, `bot_config.py`). Talks ONLY through
   Postgres. **Keep the modular split** — don't re-monolith.
2. **`schema.sql`** — single owner of the Postgres schema (folders, items, parts, tags, item_tags,
   thumbnails, jobs, upload_jobs, subtitles, bot_settings, authorized_users, LISTEN/NOTIFY triggers)
   **plus a new `users` table** for web/mobile JWT auth (shared with the api repo).
3. **`docker-compose.yml`** — orchestrates the whole scd stack (postgres, api, web, streamer, bot,
   watcher, telegram-bot-api, cloudflared).
4. **`.env.example`**, **`deploy.sh`**, **landing `README.md`**, **`CLAUDE.md`** for the new project.

## Deploy isolation (must NOT collide with the existing `tcd` stack on the same VPS)
| Aspect | scd value |
|---|---|
| VPS folder | `~/scd` (existing stack is `~/tcd` — do not touch) |
| compose project | `COMPOSE_PROJECT_NAME=scd` |
| containers | `scd-web, scd-api, scd-postgres, scd-streamer, scd-bot, scd-watcher, scd-telegram-bot-api, scd-cloudflared` |
| host ports | web 3100 · api 8090 · streamer 8088 · tg-bot-api 8181 · postgres 5433 |
| DB name/user | `scd` |
| Telegram | NEW bot token + NEW storage channel (operator supplies via `.env`) |

## Tasks
- 2A ☑ Port Python engine into `bot/` (from source). Modular split kept; runtime artifacts
       (`*.session`, logs, pids, `run-all.cmd`, autostart ps1) excluded via `.gitignore`. `py_compile` clean.
- 2B ☑ `schema.sql` incl. new `users` table (BIGINT id, name, email, password_hash, created_at;
       case-insensitive unique email via `lower()`). Appended after `authorized_users`; mirrors
       `Sarastya-project-api/db/users.sql`.
- 2C ☑ `docker-compose.yml`: all 8 services with `scd-*` names, shifted host ports (web 3100 ·
       api 8090@localhost · streamer 8088 · tg-bot-api 8181@localhost · postgres 5433@localhost),
       `scd-net`, `COMPOSE_PROJECT_NAME=scd`. **Build strategy = sibling-repo build contexts**:
       api from `../Sarastya-project-api`, web from `../Sarastya-project-web`, python engine from
       local `./bot`; all four repos cloned side-by-side under `~/scd/`. api internal-only
       (localhost host port for SSH-tunnel testing). `docker compose config` validates.
- 2D ☑ `.env.example`: NEW bot token/channel + `NEXT_PUBLIC_BOT_USERNAME` placeholders,
       `JWT_SECRET`/`JWT_EXPIRES_IN_HOURS`/`ALLOWED_ORIGINS`, DB `scd`, `COMPOSE_PROJECT_NAME`,
       copy-from-`~/tcd/.env` notes for `TG_API_ID/HASH/GROQ_API_KEYS/CLOUDFLARE_*`. Turso legacy dropped.
- 2E ☐ `deploy.sh` + CD notes for `~/scd`; landing `README.md` (links to api/web/mobile repos +
       deployed URLs + APK); project `CLAUDE.md`.
- 5  ☐ Deploy & verify on VPS; share repos with **ngertos@gmail.com**.

## Notes
- Telethon sessions in the source `bot/*.session` are for the OLD account/bot — regenerate for scd.
- API_ID/HASH are per-account (reusable); the bot token + channel are new.
- Don't reintroduce SQLite-isms; Postgres dialect only (`now_text()`, `ON CONFLICT`, `lower()`).
