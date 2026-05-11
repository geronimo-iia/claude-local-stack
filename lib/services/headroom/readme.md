# Headroom — Prompt Compression Proxy

Source: https://github.com/chopratejas/headroom
Docs: https://headroom-docs.vercel.app

Sits in front of CCR. Compresses prompts before they reach any backend (local or cloud).
Reduces token usage ~50% per request — saves context window locally, saves cost on cloud.

## Call chain position

```
Claude Code → Headroom (:8787) → CCR (:3456) → backends
```

## Optional Launch flags: LLMLingua

Loads a small LM (~300MB) for higher quality compression.

```
--llmlingua
--llmlingua-device mps    # options: auto, cuda, cpu, mps
```


## Modes

Set via `HEADROOM_MODE` env var or `--mode` flag:

| Mode             | Description                                                                  |
| ---------------- | ---------------------------------------------------------------------------- |
| `token`          | Optimize for token reduction (recommended for local models)                  |
| `cache`          | Optimize for cache hit rate (recommended for cloud APIs with prompt caching) |
| `token_headroom` | Maximize context window headroom                                             |

For local models (rapid-mlx): use `token` — fewer tokens = faster generation + longer sessions.
For cloud APIs (Bedrock/Anthropic): use `cache` — maximizes prompt caching hits to reduce cost.

## Usage

## MCP tools

- `headroom_compress` — manually compress a document
- `headroom_retrieve` — retrieve compressed content (CCR — compression is reversible)
- `headroom_stats` — compression metrics for current session

## Env vars

| Variable             | Default                 | Description                            |
| -------------------- | ----------------------- | -------------------------------------- |
| `HEADROOM_PORT`      | `8787`                  | Port the proxy listens on              |
| `HEADROOM_HOST`      | `0.0.0.0`               | Host the proxy binds to                |
| `HEADROOM_MODE`      | `token`                 | Compression strategy (see Modes above) |
| `HEADROOM_BASE_URL`  | `http://localhost:8787` | URL for consumers (SDK, agents)        |
| `HEADROOM_LOG_LEVEL` | `INFO`                  | Logging level                          |
| `HEADROOM_API_KEY`   | (none)                  | API key if proxy requires auth         |
