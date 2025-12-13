#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

URL="http://${HOST:-0.0.0.0}:${PORT:-8355}"
MODEL="${MODEL_HANDLE:-openai/gpt-oss-120b}"

echo "Base URL: $URL"
echo "Model: $MODEL"

payload=$(
  cat <<EOF
{
  "model": "${MODEL}",
  "messages": [{"role": "user", "content": "Say hello from the LAN server."}],
  "max_tokens": 64
}
EOF
)

echo
echo "Trying: POST $URL/v1/chat/completions"
set +e
curl -fsS "$URL/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d "$payload"
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
  echo
  echo "OK: /v1/chat/completions"
  exit 0
fi

echo
echo "Chat endpoint not available; trying: GET $URL/v1/models"
set +e
curl -fsS "$URL/v1/models"
rc=$?
set -e

if [[ $rc -eq 0 ]]; then
  echo
  echo "OK: /v1/models"
  exit 0
fi

echo
echo "Fallback probes: /health then /"
set +e
curl -fsS "$URL/health" && echo "OK: /health" && exit 0
curl -fsS "$URL/" && echo "OK: /" && exit 0
set -e

echo "All probes failed. Check logs with: make logs"
exit 1
