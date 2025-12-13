# API usage

This server runs inside `trtllm-serve`.

## Base URL
`http://<DGX_SPARK_LAN_IP>:<PORT>`

## Discover endpoints
Try:
- `GET /v1/models`
- `GET /health`

## Example (model list)
```bash
curl -s http://DGX_SPARK_IP:8355/v1/models | jq .
```

## Example (smoke test)

If the server provides an OpenAI-compatible chat endpoint, you can try:

```bash
curl http://DGX_SPARK_IP:8355/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-oss-120b",
    "messages": [{"role":"user","content":"Say hello from the LAN server."}],
    "max_tokens": 64
  }'
```

If that endpoint is not present in your build, check logs and the server’s published routes.
