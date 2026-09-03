# multi profile

Multi-provider routing via LiteLLM. Replaces CCR with a more capable router that supports fallbacks, cross-provider cost tracking, and dynamic switching.

## Prerequisites

All three must be true before activating this profile:
- Bedrock credentials active and tested (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`)
- Anthropic API key provisioned (`ANTHROPIC_API_KEY`)
- `LITELLM_MASTER_KEY` generated (any random string)

Add all via `ai-secrets edit`.

## Architecture

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → Ollama (:11434)   [local]
                                                   → AWS Bedrock       [cloud]
                                                   → Anthropic API     [cloud]
```

## Routing

| Route | Model | Provider |
|-------|-------|----------|
| `background` | mistral-small:24b | Ollama |
| `default` | mistral-large:123b | Ollama |
| `think` | claude-sonnet-4-5 | Bedrock |
| `longContext` | claude-sonnet-4-5 | Bedrock |
| `webSearch` | claude-opus-4-5 | Anthropic API |

Fallback: `default` falls back to `think` if Ollama is down.

## Services

- ollama (port 11434) — local inference
- litellm (port 4000) — multi-provider proxy
- headroom (port 8787) — token compression entry point
