# DGX Spark LLM Server — LAN User Guide

This DGX Spark hosts two things on the home network:

1) **Model API (OpenAI-compatible)** via TensorRT-LLM
2) **Open WebUI** (browser UI) connected to that API

## URLs (what to bookmark)

Use either:

- your Spark’s mDNS hostname (often `<spark-hostname>.local`), or
- your Spark’s LAN IPv4 address.

If your client device can’t resolve or reach the `.local` name (some networks/devices prefer IPv4 and may not like IPv6-only mDNS results), use the DGX’s LAN IP address instead.

- **Open WebUI (browser UI):**
  - `http://<spark-host-or-ip>:3000`

- **Model API health:**
  - `http://<spark-host-or-ip>:8355/health`

- **Model API (OpenAI-compatible base URL):**
  - `http://<spark-host-or-ip>:8355/v1`

- **List available models:**
  - `http://<spark-host-or-ip>:8355/v1/models`

## Use Open WebUI (recommended)

1) Open `http://<spark-host-or-ip>:3000` in a browser.
2) Create an account on first visit (local to this WebUI instance).
3) The WebUI is pre-configured to talk to the DGX model API.

If you need to configure it manually, use:

- **OpenAI API Base URL:** `http://<spark-host-or-ip>:8355/v1`
- **API Key:** any non-empty string (example: `sk-local`)

## Use the API directly (curl)

### Check health

```bash
curl -i http://<spark-host-or-ip>:8355/health
```

### List models

```bash
curl -s http://<spark-host-or-ip>:8355/v1/models
```

### Chat completion

```bash
curl http://<spark-host-or-ip>:8355/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-120b",
    "messages": [{"role":"user","content":"Hello from my laptop."}],
    "max_tokens": 128
  }'
```

## Use the API directly (Python)

Install:

```bash
python3 -m pip install --user openai
```

Example:

```python
from openai import OpenAI

client = OpenAI(
  base_url="http://<spark-host-or-ip>:8355/v1",
    api_key="sk-local",
)

resp = client.chat.completions.create(
    model="openai/gpt-oss-120b",
    messages=[{"role": "user", "content": "Hello from Python."}],
    max_tokens=128,
)

print(resp.choices[0].message.content)
```

## Always-on (after reboot)

This server is designed to come back automatically after restarts:

- The containers are configured with `restart: unless-stopped`.
- A systemd unit `dgx-spark-gpt-oss-120b.service` runs `docker compose up -d` at boot.

Operator commands (run on the DGX):

```bash
sudo systemctl status dgx-spark-gpt-oss-120b.service
sudo systemctl restart dgx-spark-gpt-oss-120b.service
```

## Security note

This API is intended for trusted LAN use. If you put this on an untrusted network, add firewall rules and/or a reverse proxy with authentication.
