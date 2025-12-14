#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

INTERVAL_SECONDS="${INTERVAL_SECONDS:-60}"
CONTAINER_NAME="${CONTAINER_NAME:-trtllm_llm_server}"
TOTAL_SHARDS="${TOTAL_SHARDS:-14}"

# Load .env if present (do not fail if missing)
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

HF_CACHE_DIR="${HF_CACHE_DIR:-/opt/hf-cache}"
PORT="${PORT:-8355}"

model_cache_dir="$HF_CACHE_DIR/hub/models--openai--gpt-oss-120b"

human_bytes() {
  python3 - <<'PY'
import os
b=float(os.environ.get('B','0'))
for unit in ['B','KiB','MiB','GiB','TiB']:
    if b < 1024 or unit == 'TiB':
        print(f"{b:.1f}{unit}")
        break
    b /= 1024
PY
}

get_last_progress_line() {
  docker logs --tail 50 "$CONTAINER_NAME" 2>/dev/null | \
    grep -E 'Downloading |Download complete|Fetching [0-9]+ files' | \
    tail -n 1 | \
    tr -d '\r' || true
}

while true; do
  now="$(date '+%Y-%m-%d %H:%M:%S %Z')"

  state="unknown"
  if docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    state="$(docker inspect --format '{{.State.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo unknown)"
  else
    state="missing"
  fi

  port_state="down"
  if ss -lntp 2>/dev/null | grep -qE ":${PORT}\\b"; then
    port_state="up"
  fi

  cache_size="?"
  if [[ -d "$HF_CACHE_DIR" ]]; then
    cache_size="$(du -sh "$HF_CACHE_DIR" 2>/dev/null | awk '{print $1}' || echo '?')"
  fi

  model_size="?"
  if [[ -d "$model_cache_dir" ]]; then
    model_size="$(du -sh "$model_cache_dir" 2>/dev/null | awk '{print $1}' || echo '?')"
  fi

  shard_count=0
  snap=""
  if [[ -d "$model_cache_dir/snapshots" ]]; then
    snap="$(ls -1dt "$model_cache_dir"/snapshots/* 2>/dev/null | head -n 1 || true)"
    if [[ -n "$snap" ]]; then
      shard_count="$(ls -1 "$snap"/model-*-of-*.safetensors 2>/dev/null | wc -l || echo 0)"
    fi
  fi

  incomplete_bytes=0
  if [[ -d "$model_cache_dir/blobs" ]]; then
    incomplete_bytes="$(find "$model_cache_dir/blobs" -maxdepth 1 -type f -name '*.incomplete' -printf '%s\n' 2>/dev/null | awk '{s+=$1} END{print s+0}')"
  fi
  export B="$incomplete_bytes"
  incomplete_human="$(human_bytes)"

  last_line="$(get_last_progress_line)"

  echo "[$now] state=$state port=$port_state cache=$cache_size model=$model_size shards=${shard_count}/${TOTAL_SHARDS} incomplete=$incomplete_human ${last_line:+| $last_line}"

  sleep "$INTERVAL_SECONDS"
done
