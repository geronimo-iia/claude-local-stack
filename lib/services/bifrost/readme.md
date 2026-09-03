# bifrost

High-performance AI gateway (Go, ~11µs overhead). Multi-provider router with semantic caching, Prometheus metrics, and a web UI. Alternative to LiteLLM in the `multi`/`mistral` profiles.

Runs via `npx` — no permanent installation. Node is managed via asdf.

## Architecture

```
Claude Code → Headroom (:8787) → Bifrost (:4000) → Ollama (:11434)   [local]
                                                  → AWS Bedrock       [cloud]
                                                  → Anthropic API     [cloud]
```

## Port

`BIFROST_PORT=4000` (set in `config/ai-stack.env`). Same port as LiteLLM — they are alternatives, not co-deployed.

## Config

Bifrost stores routing rules and provider config in `config/.bifrost/` (the `-app-dir`). Configure via:
- Web UI at `http://localhost:4000` after first launch
- REST API (`/api/v1/keys`, `/api/v1/rules`)

Routing rules map Claude Code task-type signals to providers:

| Signal | Provider | Model |
|--------|----------|-------|
| `background` | Ollama | mistral-small:24b |
| `default` | Ollama | mistral-large:123b |
| `think` | Bedrock | claude-sonnet-4-5 |
| `longContext` | Bedrock | claude-sonnet-4-5 |
| `webSearch` | Anthropic | claude-opus-4-5 |

## Ollama Setup Note

Bifrost requires `base_url` to be explicitly set for Ollama — no default. Configure in the web UI or via the API before first use.

## vs LiteLLM

See `docs/roadmap/bifrost.md` for full comparison.
LiteLLM is simpler to configure (YAML model list).
Bifrost is faster and adds semantic caching + observability.
