# max-direct profile

Headroom directly in front of Anthropic API — no LiteLLM routing layer. Minimal overhead, prompt caching works natively.

## Architecture

```
Claude Code → Headroom (:8787) → Anthropic API
```

## Prerequisites

- `ANTHROPIC_API_KEY` provisioned (Claude Max plan)

Add via `ai-secrets edit`.

## Services

| Service | Port | Role |
|---------|------|------|
| Headroom | 8787 | Token compression + cache_control + memory |

## vs max profile

| | max | max-direct |
|--|--|--|
| Routing layer | LiteLLM | None |
| Per-tier model selection | Yes | No (Headroom passes model name through) |
| Overhead | ~1 hop | Minimal |

Use `max-direct` when you don't need per-tier routing. Use `max` if you want to remap haiku/sonnet/opus to specific model versions.

## Activation

```bash
ai-stack profile max-direct
```
