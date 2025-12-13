#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .env ]]; then
  echo "Missing .env. Copy .env.example to .env and fill in values."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

mkdir -p "${HF_CACHE_DIR:-/opt/hf-cache}"

echo "Starting server with docker compose..."
docker compose up -d

echo
echo "Server is starting. Tail logs with: make logs"
echo "When ready, it should be reachable on: http://${HOST}:${PORT}"

