# aws-bedrock profile

All tiers routed to AWS Bedrock EU cross-region inference via LiteLLM. No local inference.

## Prerequisites

- Bedrock credentials active (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION=eu-west-1`)
- `LITELLM_MASTER_KEY` set

Add via `ai-secrets edit`.

## Architecture

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → AWS Bedrock EU
```

## Routing

| Tier | Model | Notes |
|------|-------|-------|
| `claude-haiku*` | `eu.anthropic.claude-haiku-4-5-20251001-v1:0` | Background / cheap tasks |
| `claude-sonnet*` | `eu.anthropic.claude-sonnet-5` | Everyday tasks |
| `claude-opus*` | `eu.anthropic.claude-opus-5` | Heavy reasoning |
| catch-all | `eu.anthropic.claude-sonnet-5` | Fallback |

## Services

| Service | Port | Role |
|---------|------|------|
| LiteLLM | 4000 | Proxy, model routing |
| Headroom | 8787 | Memory-augmented proxy between Claude Code and LiteLLM |

## Activation

```bash
ai-stack profile aws-bedrock
```
