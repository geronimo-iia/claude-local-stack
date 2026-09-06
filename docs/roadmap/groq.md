# Roadmap: Groq Integration

Groq is an OpenAI-compatible inference API (Llama, Qwen, Mixtral). Very low latency, generous free tier. Does NOT host Claude models — Claude Code receives Llama/Qwen responses when Groq is active.

## Status

Not yet implemented. The previous design used LiteLLM as the routing layer, which has been removed. A Groq integration now requires bifrost provider config.

## Bifrost wiring (when ready)

Add a `groq` provider to `config/profiles/<profile>/bifrost/config.json`:

```json
{
  "providers": {
    "openai": {
      "keys": [{
        "name": "groq",
        "models": ["*"],
        "weight": 1.0,
        "value": "env.GROQ_API_KEY",
        "network_config": {
          "base_url": "https://api.groq.com/openai/v1"
        },
        "aliases": {
          "claude-sonnet-4-6": "qwen-qwq-32b",
          "claude-haiku-4-5": "llama-3.1-8b-instant"
        }
      }]
    }
  }
}
```

Add `GROQ_API_KEY` to secrets:

```bash
ai-secrets edit   # add GROQ_API_KEY: gsk_...
```

## Model tiers

| Model | Slot | Notes |
|-------|------|-------|
| `qwen-qwq-32b` | sonnet (default) | Strong reasoning and coding |
| `llama-3.3-70b-versatile` | sonnet fallback | When QwQ is rate-limited |
| `llama-3.1-8b-instant` | haiku (background) | Speed-optimised |

## Rate limits

Free tier: 30 RPM / 6k TPM (llama-3.3-70b). One heavy Claude Code turn exhausts this. Groq is best as a fallback, not a primary for intensive sessions. Paid tier (1k RPM / 100k+ TPM) is viable for secondary workloads.
