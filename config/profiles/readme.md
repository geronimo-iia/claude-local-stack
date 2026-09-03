# Profiles

Switch with `ai-stack profile <name>`.

| Profile | Router | Backend | Min RAM | Notes |
|---------|--------|---------|---------|-------|
| [max](max/readme.md) | LiteLLM | Anthropic direct + rapid-mlx fallback | 32 GB | Claude Max plan, prompt caching works, 429 auto-fallback to local |
| [local](local/readme.md) | LiteLLM | rapid-mlx | 32 GB | Qwen3.6 MoE, fully local, fast on Apple Silicon |
| [mistral](mistral/readme.md) | LiteLLM | Ollama | 128 GB | Mistral Large 2 (all tiers), 128k context, air-gapped — **2–3 min/response, batch/offline only** |
| [mistral-light](mistral-light/readme.md) | LiteLLM | Ollama | 16 GB | Mistral Small — **unusable interactively** (3+ min/response), batch/offline only |
| [aws-bedrock](aws-bedrock/readme.md) | LiteLLM | AWS Bedrock EU | — | All tiers cloud (haiku 4.5, sonnet 5, opus 5 via Bedrock EU cross-region) |
| [bedrock-direct](bedrock-direct/readme.md) | — | AWS Bedrock | — | Headroom → Bedrock directly, no routing layer |
