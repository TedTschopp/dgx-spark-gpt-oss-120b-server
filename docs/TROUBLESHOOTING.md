# Troubleshooting

## Container starts but API not reachable on LAN

- Ensure Spark host firewall allows inbound TCP on `PORT` (default 8355).
- Confirm you're binding to `0.0.0.0` (HOST env).
- From another machine: `curl http://<spark-host-or-ip>:8355/v1/models`

Also note: `0.0.0.0` is only valid for *binding*, not for *connecting*. From the Spark host, connect to `http://127.0.0.1:PORT/...`.

## Out of memory / crashes during load

- Lower `free_gpu_memory_fraction` in `config/extra-llm-api-config.yml` (e.g., 0.85).
- Reduce `--max_batch_size` in `docker-compose.yml` (e.g., 8–16).

## Downloads are slow every boot

- Confirm `HF_CACHE_DIR` is set and mounted correctly.
- Confirm the host directory exists and is writable.

## Hugging Face download fails with XetHub `403 Forbidden`

Symptoms: logs show errors like `transfer.xethub.hf.co` and `403 Forbidden`, and downloads stall.

This repo disables XetHub downloads inside the container (see `HF_HUB_DISABLE_XET=1` in `docker-compose.yml`). If you pulled older config, update and restart:

```bash
make down
make up
```

## Docker permission denied

Symptoms: `permission denied` accessing `/var/run/docker.sock`.

Fix (typical): add your user to the `docker` group, re-login, or run `newgrp docker`.

## NVIDIA runtime not found

- Run `make prereqs`
- Confirm `docker run --gpus all ... nvidia-smi` works.

If your Docker setup doesn’t recognize `runtime: nvidia`, this repo uses the modern Compose GPU syntax (`gpus: all`).
