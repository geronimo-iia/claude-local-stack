# Bifrost

[Bifrost](https://www.getbifrost.ai) is the Go gateway used by all profiles that need provider routing. Three roles in one process:

1. **LLM Router** — multi-provider routing via model aliases, weight-based load balancing, fallback
2. **MCP Aggregator** — connects to all MCP servers, exposes them as a single `/mcp` endpoint
3. **Skills Marketplace** — hosts versioned agent skills, registers as a Claude Code marketplace source

Installed via `npx -y @maximhq/bifrost` (Go binary distributed as npm package).

## Current deployment

All profiles route through bifrost at port 4000 except `max-direct` and `bedrock-direct` (headroom talks directly to the provider):

| Profile        | Provider                      | Credentials source              |
| -------------- | ----------------------------- | ------------------------------- |
| local          | OpenAI-compatible (rapid-mlx) | none                            |
| mistral        | OpenAI-compatible (Ollama)    | none                            |
| mistral-light  | OpenAI-compatible (Ollama)    | none                            |
| rapid-mlx-test | OpenAI-compatible (rapid-mlx) | none                            |
| max            | Anthropic native              | `env.ANTHROPIC_API_KEY`         |
| bedrock        | Bedrock SigV4                 | `profiles/bedrock/bifrost.env`  |

Config: `config/.bifrost/config.json` (copied from active profile on switch). Uses `"env.VAR_NAME"` references resolved at startup — no `envsubst` templating.

## Next levers (not yet wired)

**MCP aggregation** — once MCP server count grows beyond 3, replace per-server `~/.claude.json` entries with a single bifrost `/mcp` endpoint:

```
MCP servers (llm-wiki, headroom-memory, filesystem…)
    ↓  bifrost connects as MCP client
bifrost /mcp  ← single aggregated endpoint
    ↓  Claude Code registers once
```

**Semantic caching** — reduce Bedrock/Anthropic spend. Bifrost supports exact hash + vector similarity cache, requires a vector store.

**Observability** — bifrost exposes Prometheus metrics + web UI at `/ui`. Useful when debugging routing or latency.

**Skills marketplace** — host versioned skills locally:

```bash
claude plugin install http://localhost:4000/skills
```

## Gotcha

`base_url` must be explicitly set for Ollama in `config.json` — no default. Requests fail silently without it.
