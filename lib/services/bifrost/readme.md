# bifrost

High-performance AI gateway (Go, ~11µs overhead). Multi-provider router with Anthropic→OpenAI conversion, semantic caching, Prometheus metrics, and a web UI. Replaces LiteLLM for profiles that need correct tool-call handling on OpenAI-compatible local backends.

Runs via `npx @maximhq/bifrost` — no permanent installation. Node is managed via asdf.

## Architecture

```
Claude Code → Headroom (:8787) → Bifrost (:4000/anthropic) → rapid-mlx (:8000)  [rapid-mlx-test]
                                                           → Ollama (:11434)      [future]
                                                           → AWS Bedrock          [future]
```

Headroom uses `--anthropic-api-url http://localhost:4000/anthropic` — bifrost accepts Anthropic-format requests at `/anthropic`, converts to OpenAI, forwards to the backend provider.

## Port

`BIFROST_PORT=4000` (set in `config/ai-stack.env`). Same port as LiteLLM — they are alternatives, not co-deployed.

## Config

Each profile carries its own `bifrost/config.json` (file-only mode — no SQLite DB). Activation copies `profile/bifrost/` → `config/.bifrost/`.

`config_store.enabled: false` in `config.json` makes bifrost read only from the file, never creating a DB. Clean, portable, GitOps-friendly.

### Custom OpenAI-compatible provider (rapid-mlx pattern)

```json
{
  "providers": {
    "rapid-mlx": {
      "keys": [{
        "name": "rapid-mlx-key",
        "value": "local",
        "models": ["*"],
        "weight": 1.0,
        "aliases": {
          "claude-sonnet-4-5": "mlx-community/DeepSeek-Coder-V2-Lite-Instruct-4bit-mlx",
          "*": "mlx-community/DeepSeek-Coder-V2-Lite-Instruct-4bit-mlx"
        }
      }],
      "network_config": {
        "base_url": "http://localhost:8000",
        "default_request_timeout_in_seconds": 600
      },
      "custom_provider_config": {
        "base_provider_type": "openai",
        "allowed_requests": {
          "chat_completion": true,
          "chat_completion_stream": true
        }
      }
    }
  },
  "config_store": { "enabled": false }
}
```

`aliases` maps request model name → actual model name sent to backend. Use `"*"` as a catch-all.
`base_url` is the server root — bifrost appends `/v1/chat/completions` itself.

## Endpoints

| Endpoint | Format | Use |
|----------|--------|-----|
| `POST /anthropic/v1/messages` | Anthropic | headroom upstream (`--anthropic-api-url`) |
| `POST /v1/chat/completions` | OpenAI | direct OpenAI clients |
| `GET /health` | — | health check |
| `http://localhost:4000` | Web UI | provider config, routing rules, logs |

The web UI is a JavaScript SPA — requires a browser, not `curl`.

## Why bifrost instead of LiteLLM

LiteLLM's `/v1/messages` (Anthropic format) path strips `tools` before forwarding to OpenAI-compatible backends. Tool schemas never reach the model; responses come back with `stop_reason: end_turn` and empty content. This is a known upstream bug in litellm's Anthropic proxy path.

Bifrost handles the Anthropic→OpenAI conversion correctly — tools are preserved and forwarded.

LiteLLM's `/v1/chat/completions` (OpenAI format) path works, but headroom's `--anthropic-api-url` flag only supports Anthropic-format upstreams.

## vs LiteLLM

| | LiteLLM | Bifrost |
|--|---------|---------|
| Config | YAML `model_list` | `config.json` (file-only or DB) |
| Anthropic→OpenAI tool conversion | Broken on `/v1/messages` | Correct |
| Runtime | Python (slow cold start) | Go (~11µs overhead) |
| Semantic cache | No (OSS) | Yes |
| Web UI | No (OSS) | Yes (`http://localhost:4000`) |
| Install | `uvx --from litellm litellm` | `npx @maximhq/bifrost` |

## launch scripts

| Script | Backend | Notes |
|--------|---------|-------|
| `launch-bifrost` | bifrost | headroom for bifrost profiles; uses `--anthropic-api-url .../anthropic` |
| `launch-litellm` | litellm | headroom for litellm profiles |
