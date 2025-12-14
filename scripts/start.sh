#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

docker_cmd() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
    return
  fi

  local cmd
  cmd="$(printf '%q ' docker "$@")"
  sg docker -c "$cmd"
}

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
docker_cmd compose up -d

echo
echo "Server is starting. Tail logs with: make logs"

BIND_HOST="${HOST:-0.0.0.0}"
CONNECT_HOST="$BIND_HOST"
if [[ "$CONNECT_HOST" == "0.0.0.0" || "$CONNECT_HOST" == "::" ]]; then
  CONNECT_HOST="127.0.0.1"
fi

echo "Local API:  http://${CONNECT_HOST}:${PORT}"
echo "Local WebUI: http://${CONNECT_HOST}:3000"
echo "LAN access: replace ${CONNECT_HOST} with your Spark host/IP"

