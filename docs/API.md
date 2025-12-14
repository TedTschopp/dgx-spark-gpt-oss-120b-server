# API usage

This server runs inside `trtllm-serve`.

## Base URL

`http://<spark-host-or-ip>:<port>`

## Discover endpoints

Try:

- `GET /v1/models`
- `GET /health`

If the server isn’t responding yet, it’s usually still downloading/loading the model. From the Spark host, you can monitor progress with:

```bash
make watch
```

## Example (model list)

```bash
curl http://<spark-host-or-ip>:8355/health
curl -s http://<spark-host-or-ip>:8355/v1/models | jq .
```

## Example (smoke test)

If the server provides an OpenAI-compatible chat endpoint, you can try:

```bash
curl http://<spark-host-or-ip>:8355/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-120b",
    "messages": [{"role":"user","content":"Say hello from the LAN server."}],
    "max_tokens": 64
  }'
```

If that endpoint is not present in your build, check logs and the server’s published routes.
