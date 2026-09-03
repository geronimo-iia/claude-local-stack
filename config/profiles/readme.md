# Profiles

Switch with `ai-stack profile <name>`.

| Profile | Router | Backend | Min RAM | Notes |
|---------|--------|---------|---------|-------|
| [default](default/readme.md) | CCR | rapid-mlx (1×) | 32 GB | Single MoE model, fully local |
| [mistral](mistral/readme.md) | LiteLLM | Ollama | 128 GB | Mistral Large 2 (all tiers), extended context |
| [mistral-light](mistral-light/readme.md) | LiteLLM | Ollama (1×) | 16 GB | Mistral Small only, fast + low RAM |
| [multi](multi/readme.md) | LiteLLM | Ollama + Bedrock + Anthropic | 128 GB | Multi-provider with fallback |
| [cloud](cloud/readme.md) | — | AWS Bedrock | any | No local inference, Bedrock only |
