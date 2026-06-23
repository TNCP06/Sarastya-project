#!/bin/bash
# Deploy / redeploy the whole Sarastya Drive (scd) stack on the VPS, from ~/scd/Sarastya-project.
#
# Layout assumed (all four repos cloned side-by-side under ~/scd):
#   ~/scd/Sarastya-project      (this repo — run this script here)
#   ~/scd/Sarastya-project-api  (built as scd-api)
#   ~/scd/Sarastya-project-web  (built as scd-web)
#
# First run only:
#   1) cp .env.example .env  &&  edit it (POSTGRES_PASSWORD, JWT_SECRET, NEW bot token/channel,
#      TG_API_ID/HASH + GROQ_API_KEYS copied from ~/tcd/.env).
#   2) Create the NEW Telethon sessions: bot/worker.session and bot/streamer.session.
#   3) ./deploy.sh   (scd-postgres applies bot/schema.sql automatically on the empty volume).
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# Pull latest for the three buildable repos (skip any that aren't present).
for repo in . ../Sarastya-project-api ../Sarastya-project-web; do
  if [ -d "$repo/.git" ]; then
    echo "── git pull: $repo"
    git -C "$repo" pull origin feat/cloud-drive
  fi
done

echo "── building + starting scd stack"
docker compose -p scd up -d --build

echo "── status"
docker compose -p scd ps
