#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${CONTAINER_NAME:-trtllm_llm_server}"

docker_cmd() {
	if docker info >/dev/null 2>&1; then
		docker "$@"
		return
	fi

	local cmd
	cmd="$(printf '%q ' docker "$@")"
	sg docker -c "$cmd"
}

docker_cmd logs --tail 200 -f "$CONTAINER_NAME"
