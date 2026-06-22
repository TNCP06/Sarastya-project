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
- 2A ☐ Port Python engine into this repo (from source `bot/`). Keep modular split.
- 2B ☐ `schema.sql` incl. new `users` table (id, email/username UNIQUE, password_hash, created_at).
- 2C ☐ `docker-compose.yml`: all services, `scd-` names, new host ports, `scd-net`,
       `COMPOSE_PROJECT_NAME=scd`. Decide build strategy for api/web images (build context per repo
       vs prebuilt). streamer→stream domain, web→drive domain; api internal-only.
- 2D ☐ `.env.example`: new bot token/channel placeholders, `Jwt__Secret`, DB `scd`, notes to copy
       `TG_API_ID/HASH/GROQ_API_KEYS` from `~/tcd/.env`.
- 2E ☐ `deploy.sh` + CD notes for `~/scd`; landing `README.md` (links to api/web/mobile repos +
       deployed URLs + APK); project `CLAUDE.md`.
- 5  ☐ Deploy & verify on VPS; share repos with **ngertos@gmail.com**.

## Notes
- Telethon sessions in the source `bot/*.session` are for the OLD account/bot — regenerate for scd.
- API_ID/HASH are per-account (reusable); the bot token + channel are new.
- Don't reintroduce SQLite-isms; Postgres dialect only (`now_text()`, `ON CONFLICT`, `lower()`).
