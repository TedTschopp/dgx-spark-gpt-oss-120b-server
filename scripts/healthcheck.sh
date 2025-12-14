#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
if [[ -f .env ]]; then source .env; fi

BIND_HOST="${HOST:-0.0.0.0}"
CONNECT_HOST="$BIND_HOST"
if [[ "$CONNECT_HOST" == "0.0.0.0" || "$CONNECT_HOST" == "::" ]]; then
	CONNECT_HOST="127.0.0.1"
fi

URL="http://${CONNECT_HOST}:${PORT:-8355}"

echo "Probing: $URL"
# The server may expose different endpoints depending on version.
# We try a small set of common ones.
set +e
curl -fsS "$URL/health" && echo "OK: /health" && exit 0
curl -fsS "$URL/v1/models" && echo "OK: /v1/models" && exit 0
curl -fsS "$URL/" && echo "OK: /" && exit 0
set -e

echo "Health check failed (server may still be loading the model). Check logs: make logs"
exit 1
