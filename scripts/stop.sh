#!/usr/bin/env bash
set -euo pipefail

docker_cmd() {
	if docker info >/dev/null 2>&1; then
		docker "$@"
		return
	fi

	local cmd
	cmd="$(printf '%q ' docker "$@")"
	sg docker -c "$cmd"
}

docker_cmd compose down
echo "Stopped."
