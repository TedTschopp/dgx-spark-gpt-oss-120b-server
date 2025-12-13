# DGX Spark — gpt-oss-120b LAN API Server (TensorRT-LLM)

This repo runs `openai/gpt-oss-120b` as an API server on an NVIDIA DGX Spark, reachable from your home network.

## Quick start

1) Copy env file and set secrets:
```bash
cp .env.example .env
# edit .env and set HF_TOKEN
```

2. (Optional) prereqs check:

```bash
make prereqs
```

3. Start the server:

```bash
make up
```

4. Tail logs:

```bash
make logs
```

5. Health check:

```bash
make health
```

## Calling from another machine on your LAN

Find your Spark’s LAN IP (e.g. `192.168.1.50`) and call:

```bash
curl http://192.168.1.50:8355/v1/models
```

More examples: see `docs/API.md`.

## Notes

* First run downloads many GB of weights into `HF_CACHE_DIR` (default `/opt/hf-cache`).
* Keep `.env` out of git; use `.env.example` as a template.
