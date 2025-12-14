# Instructions for GitHub Copilot: Bring up DGX Spark LAN Server

Use this file as a runbook to get `openai/gpt-oss-120b` serving on a DGX Spark via Docker + TensorRT-LLM.

## 0) Assumptions

- You are running these commands **on the DGX Spark host**.
- You have **Docker Engine** installed and working.
- You have **NVIDIA drivers + nvidia-container-toolkit** installed and `docker run --gpus all ...` works.
- Your DGX can reach:
  - `nvcr.io` (to pull the TensorRT-LLM image)
  - `huggingface.co` (to download model files)
- You have a Hugging Face token (`HF_TOKEN`) that can access `openai/gpt-oss-120b`.

## 1) Get the repo onto the DGX Spark

Option A (clone):

```bash
git clone https://github.com/TedTschopp/dgx-spark-gpt-oss-120b-server.git
cd dgx-spark-gpt-oss-120b-server
```

Option B (already cloned):

```bash
git pull
```

## 2) Create `.env`

Create your local secret file (never commit this):

```bash
cp .env.example .env
```

Edit `.env` and set at least:

- `HF_TOKEN=...`
- `MODEL_HANDLE=openai/gpt-oss-120b`
- `HF_CACHE_DIR=/opt/hf-cache` (or any large disk path)
- `HOST=0.0.0.0`
- `PORT=8355`
- `TRTLLM_IMAGE=nvcr.io/nvidia/tensorrt-llm/release:spark-single-gpu-dev`

Create the cache directory (the scripts also do this, but it’s useful to verify permissions):

```bash
# uses HF_CACHE_DIR from .env
set -a; source .env; set +a
sudo mkdir -p "$HF_CACHE_DIR"
# ensure the user running docker can write to it; adjust to your policy
sudo chown -R "$USER" "$HF_CACHE_DIR"
```

## 3) Prereqs check (recommended)

```bash
make prereqs
```

If this fails:

- Fix Docker install first
- Fix NVIDIA container runtime (nvidia-container-toolkit) so `docker run --gpus all ... nvidia-smi` works

If you get Docker permission errors (cannot connect to `/var/run/docker.sock`), ensure your user can run Docker (e.g., add to the `docker` group, then re-login or run `newgrp docker`).

## 4) Pull the TensorRT-LLM image (optional but speeds first start)

```bash
set -a; source .env; set +a
docker pull "$TRTLLM_IMAGE"
```

## 5) Start the server

```bash
make up
```

Then watch logs:

```bash
make logs
```

Or watch a compact status line (recommended during long downloads):

```bash
make watch
```

Adjust the update interval (seconds):

```bash
INTERVAL_SECONDS=120 make watch
```

Notes:

- First run may take a long time (many GB download/build/cache).
- The server won’t respond until the model is loaded.

If downloads error with `403 Forbidden` from `transfer.xethub.hf.co` (XetHub), this repo disables XetHub downloads inside the container so it falls back to standard Hugging Face downloads.

## 6) Check readiness (from the DGX host)

```bash
make health
```

Or try the smoke test script:

```bash
bash scripts/test_chat.sh
```

## 7) Call it from another machine on your LAN

1) Find the DGX Spark LAN IP (examples):

```bash
# on the DGX
ip -br -4 addr

# or: show the IP used for outbound traffic (often the right LAN IP)
ip route get 1.1.1.1 | sed -n '1p'
```

1) From your laptop/desktop on the same LAN, replace `DGX_IP`:

```bash
curl http://DGX_IP:8355/health
curl -s http://DGX_IP:8355/v1/models
```

If `/v1/chat/completions` is available:

```bash
curl http://DGX_IP:8355/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-120b",
    "messages": [{"role":"user","content":"Hello from LAN."}],
    "max_tokens": 64
  }'
```

## 8) Stop / status

```bash
make status
make down
```

## 8b) Make it start automatically on boot

This repo includes a `systemd` unit that runs `docker compose up -d` at boot.

```bash
sudo bash scripts/install_autostart.sh
```

Verify:

```bash
systemctl status dgx-spark-gpt-oss-120b.service
```

## 9) LAN exposure checklist (important)

- `HOST=0.0.0.0` makes the service reachable on your LAN.
- Ensure your host firewall allows inbound TCP to `PORT` **only from networks you trust**.
- If you want authentication, add a reverse proxy in front (see docs/SECURITY.md).

## 10) Quick troubleshooting

- Health checks fail but logs show downloads: wait longer; model load can take time.
- “Out of memory” during load:
  - Lower `free_gpu_memory_fraction` in `config/extra-llm-api-config.yml`.
  - Reduce `--max_batch_size` in `docker-compose.yml`.
- “API not reachable from LAN”:
  - Confirm `HOST=0.0.0.0`.
  - Confirm host firewall allows inbound `PORT`.
  - Try `curl http://DGX_IP:PORT/v1/models` from another machine.

## 11) Prompt Copilot with a simple operational checklist

Paste this into Copilot Chat on the DGX:

> Verify `.env` exists and has HF_TOKEN, HOST, PORT, HF_CACHE_DIR, TRTLLM_IMAGE.
> Run `make prereqs` and explain any failures.
> Run `make up`, then `make logs` until the server is ready.
> Run `make health` and `bash scripts/test_chat.sh`.
> Explain how to curl `/v1/models` from another machine on the LAN.
