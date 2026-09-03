# max profile

Anthropic direct API (Claude Max plan) as primary, local rapid-mlx as automatic fallback on rate-limit (429).

Prompt caching works natively — Headroom places `cache_control` at stable prefix boundaries. Unlike Bedrock (eu-west-1 Converse API), the Anthropic Messages API honors cache reads, cutting costs 10x on repeated context.

## Architecture

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → Anthropic API  [primary]
                                                  → rapid-mlx :8000 [429 fallback]
```

## Prerequisites

- `ANTHROPIC_API_KEY` provisioned (Claude Max plan)
- local Qwen3.6 model downloaded (`ai-models pull llm`)

Add key via `ai-secrets edit`.

## Routing

| Tier | Model | Notes |
|------|-------|-------|
| `claude-haiku*` | `claude-haiku-4-5-20251001` | Anthropic direct |
| `claude-sonnet*` | `claude-sonnet-5` | Anthropic direct |
| `claude-opus*` | `claude-opus-5` | Anthropic direct |
| `local-fallback` | Qwen3.6-35B-A3B-OptiQ | Auto on 429 |

## Services

| Service | Port | Role |
|---------|------|------|
| rapid-mlx | 8000 | Local inference (fallback) |
| LiteLLM | 4000 | Routing + 429 fallback logic |
| Headroom | 8787 | Token compression + cache_control |

## Why not aws-bedrock?

Bedrock eu-west-1 Converse API does not support prompt caching — `cache_read_tokens: 0` across all sessions. Full input price every turn. Direct Anthropic API caches at $0.30/MTok vs $3/MTok (10x cheaper on repeated context).

## Activation

```bash
# Verify ANTHROPIC_API_KEY is set
ai-secrets env | grep ANTHROPIC

ai-stack profile max
```
