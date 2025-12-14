# DGX Spark — gpt-oss-120b LAN API Server (TensorRT-LLM)

This repo runs `openai/gpt-oss-120b` as an API server on an NVIDIA DGX Spark, reachable from your home network.

## Quick start

1) Copy env file and set secrets:

```bash
cp .env.example .env
# edit .env and set HF_TOKEN
```

1) (Optional) prereqs check:

```bash
make prereqs
```

If you see Docker permission errors (cannot connect to `/var/run/docker.sock`), add your user to the `docker` group and re-login (or run `newgrp docker`).

1) Start the server:

```bash
make up
```

1) Tail logs:

```bash
make logs
```

Or watch a compact one-line status update (recommended during long downloads):

```bash
INTERVAL_SECONDS=120 make watch
```

1) Health check:

```bash
make health
```

Note: if you bind `HOST=0.0.0.0`, local health/smoke tests will still connect via `127.0.0.1` (because `curl http://0.0.0.0:PORT` is not a valid destination).

## Calling from another machine on your LAN

Find your Spark’s LAN IP (e.g. `192.168.1.50`) and call:

```bash
curl http://192.168.1.50:8355/health
curl http://192.168.1.50:8355/v1/models
```

More examples: see `docs/API.md`.

LAN setup / end-user docs: see `docs/LAN-USER-GUIDE.md`.

## Open WebUI (optional UI)

This repo can also run Open WebUI (a browser UI) alongside the API.

- Start it (included in `make up`):

```bash
docker compose up -d open-webui
```

- Open in your browser:

```text
http://<DGX_IP>:3000
```

## Start on boot (auto-start)

The container uses `restart: unless-stopped`, so once the Docker Compose stack has been created, it will come back after a reboot when Docker starts.

To make it explicit (and to ensure the stack is created on boot), install the provided systemd unit:

```bash
sudo bash scripts/install_autostart.sh
```

After that, you can reboot and verify:

```bash
systemctl status dgx-spark-gpt-oss-120b.service
curl http://<DGX_IP>:8355/health
```

## Notes

- First run downloads many GB of weights into `HF_CACHE_DIR` (default `/opt/hf-cache`).
- Keep `.env` out of git; use `.env.example` as a template.
- If downloads fail with `403 Forbidden` from `transfer.xethub.hf.co`, this repo disables XetHub downloads in the container and uses standard Hugging Face downloads instead.
