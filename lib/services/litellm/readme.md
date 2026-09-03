# litellm

Multi-provider LLM proxy. Routes requests to Ollama, AWS Bedrock, or Anthropic API based on model name.

Used in the `multi` profile as a replacement for CCR. Headroom still sits in front as the Claude Code entry point.

Runs via `uvx` — no permanent installation. uv caches the environment on first launch.

## Architecture

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → Ollama (:11434)   [local]
                                                   → AWS Bedrock       [cloud]
                                                   → Anthropic API     [cloud]
```

## Config

Config lives at `config/litellm.yaml` — copied from `config/profiles/multi/litellm.yaml` on profile activation.

## Port

`LITELLM_PORT=4000` (set in `config/ai-stack.env`).

## Secrets

LiteLLM reads credentials from environment variables injected by `ai-secrets`:

- `ANTHROPIC_API_KEY` — Anthropic direct API
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_REGION` — Bedrock
- `LITELLM_MASTER_KEY` — secures the proxy API

Add via `ai-secrets edit`.
