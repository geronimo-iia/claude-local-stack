# Profiles

Switch with `ai-stack profile <name>`.

| Profile | Router | Backend | Min RAM | Notes |
|---------|--------|---------|---------|-------|
| [local](local/readme.md) | LiteLLM | rapid-mlx | 32 GB | Qwen3.6 MoE, fully local, fast on Apple Silicon |
| [mistral](mistral/readme.md) | LiteLLM | Ollama | 128 GB | Mistral Large 2 (all tiers), 128k context, air-gapped |
| [mistral-light](mistral-light/readme.md) | LiteLLM | Ollama | 16 GB | Mistral Small — batch/offline only, too slow for interactive use |
| [multi](multi/readme.md) | LiteLLM | Bedrock + Anthropic | — | All tiers cloud (haiku/sonnet → Bedrock, opus → Anthropic) |
| [cloud](cloud/readme.md) | — | AWS Bedrock | — | No local inference, Bedrock only |
