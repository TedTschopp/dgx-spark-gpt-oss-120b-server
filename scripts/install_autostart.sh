#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE_NAME="dgx-spark-gpt-oss-120b.service"
SERVICE_SRC="$ROOT/systemd/$SERVICE_NAME"
SERVICE_DST="/etc/systemd/system/$SERVICE_NAME"

if [[ ! -f "$ROOT/.env" ]]; then
  echo "Missing .env. Copy .env.example to .env and fill in values first."
  exit 1
fi

if [[ ! -f "$SERVICE_SRC" ]]; then
  echo "Missing $SERVICE_SRC"
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (use: sudo $0)"
  exit 1
fi

echo "Installing systemd unit: $SERVICE_DST"
install -m 0644 "$SERVICE_SRC" "$SERVICE_DST"

echo "Reloading systemd..."
systemctl daemon-reload

echo "Enabling Docker to start on boot (if not already)..."
systemctl enable --now docker

echo "Enabling model server to start on boot..."
systemctl enable --now "$SERVICE_NAME"

echo
echo "Status:"
systemctl --no-pager --full status "$SERVICE_NAME" || true

echo
echo "Done. After reboot, the server should come up automatically."
