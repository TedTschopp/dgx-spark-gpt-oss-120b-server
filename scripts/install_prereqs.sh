#!/usr/bin/env bash
set -euo pipefail

echo "== DGX Spark prereqs check =="

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Install Docker Engine first."
  exit 1
fi

echo "Docker: OK"

docker_cmd() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
    return
  fi

  local cmd
  cmd="$(printf '%q ' docker "$@")"
  sg docker -c "$cmd"
}

# Quick sanity check that NVIDIA runtime is visible
# This is intentionally lightweight; exact command may vary by your base image.
echo "Checking NVIDIA GPU visibility in containers..."
if docker_cmd run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi >/dev/null 2>&1; then
  echo "NVIDIA Container runtime: OK"
else
  echo "NVIDIA Container runtime check failed."
  echo "Make sure NVIDIA drivers + nvidia-container-toolkit are installed and configured."
  exit 1
fi

echo "All checks passed."
