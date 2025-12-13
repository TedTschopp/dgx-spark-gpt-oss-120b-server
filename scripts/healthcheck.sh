#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
if [[ -f .env ]]; then source .env; fi

URL="http://${HOST:-0.0.0.0}:${PORT:-8355}"

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
