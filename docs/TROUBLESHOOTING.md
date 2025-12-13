# Troubleshooting

## Container starts but API not reachable on LAN
- Ensure Spark host firewall allows inbound TCP on `PORT` (default 8355).
- Confirm you're binding to `0.0.0.0` (HOST env).
- From another machine: `curl http://SPARK_IP:8355/v1/models`

## Out of memory / crashes during load
- Lower `free_gpu_memory_fraction` in `config/extra-llm-api-config.yml` (e.g., 0.85).
- Reduce `--max_batch_size` in `docker-compose.yml` (e.g., 8–16).

## Downloads are slow every boot
- Confirm `HF_CACHE_DIR` is set and mounted correctly.
- Confirm the host directory exists and is writable.

## NVIDIA runtime not found
- Run `make prereqs`
- Confirm `docker run --gpus all ... nvidia-smi` works.
