#!/usr/bin/env bash
set -euo pipefail

docker logs --tail 200 -f trtllm_llm_server
