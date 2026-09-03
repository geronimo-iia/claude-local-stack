# max profile

Anthropic direct API (Claude Max plan). No fallback — Max plan limits are high enough that 429s are not a practical concern.

Prompt caching works natively — Headroom places `cache_control` at stable prefix boundaries. Unlike Bedrock (eu-west-1 Converse API), the Anthropic Messages API honors cache reads, cutting costs 10x on repeated context.

## Architecture

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → Anthropic API
```

## Prerequisites

- `ANTHROPIC_API_KEY` provisioned (Claude Max plan)

Add key via `ai-secrets edit`.

## Routing

| Tier | Model |
|------|-------|
| `claude-haiku*` | `claude-haiku-4-5-20251001` |
| `claude-sonnet*` | `claude-sonnet-5` |
| `claude-opus*` | `claude-sonnet-5` (Opus not in Max plan) |

## Services

| Service | Port | Role |
|---------|------|------|
| LiteLLM | 4000 | Proxy, model routing |
| Headroom | 8787 | Token compression + cache_control |

## Why not aws-bedrock?

Bedrock eu-west-1 Converse API does not support prompt caching — `cache_read_tokens: 0` across all sessions. Full input price every turn. Direct Anthropic API caches at $0.30/MTok vs $3/MTok (10x cheaper on repeated context).

## Activation

```bash
# Verify ANTHROPIC_API_KEY is set
ai-secrets env | grep ANTHROPIC

ai-stack profile max
```
