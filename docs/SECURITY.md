# Security notes (LAN-exposed inference server)

This repo starts a TensorRT-LLM server bound to `HOST:PORT` (default `0.0.0.0:8355`) using host networking. That makes the API reachable by other devices on the same network.

## Risks

- **No authentication by default**: anyone who can reach the port can send requests.
- **LAN exposure**: home networks can still include guests, IoT devices, and misconfigured routing.
- **Cost/abuse**: requests can consume GPU/CPU, fill disk cache, or create noisy logs.

## Safer defaults (pick one)

### 1) Bind only to localhost (no LAN access)

Set in `.env`:

```bash
HOST=127.0.0.1
```

Then access via SSH port-forwarding from another machine.

### 2) Keep LAN access, restrict the port in the host firewall

Allow only specific source IPs/subnets to connect to `PORT`.

Examples (conceptual):

- `ufw`: allow `PORT` from your workstation IP, deny others
- `firewalld`: rich rules to allow only your subnet or specific hosts

### 3) Put a reverse proxy in front (recommended if multiple clients)

Use a reverse proxy (Caddy/Nginx) to add:

- an API key / bearer token check
- TLS (optional on LAN)
- IP allow-listing / rate limits

This repo does not ship a proxy by default; add one only if you need authentication.
