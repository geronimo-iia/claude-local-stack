# Models

Declared in `config/models.yaml`. Downloaded via `ai-models pull`. HuggingFace models stored in `~/.cache/huggingface/hub/`, Ollama models in `~/.ollama/models/`.

## Manifest format

```yaml
ollama:
  - mistral-small:24b                        # Mistral Small 3.1, ~14 GB
  - qwen3.8:27b-mtp-q4_K_M                  # Qwen3.8 27B dense, ~18 GB
  - qwen3:30b-a3b-instruct-2507-q4_K_M      # Qwen3 30B MoE, ~19 GB

llm:
  - mlx-community/Qwen3.8-27B-MTP-4bit
  - mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B

embedding:
  - mlx-community/Qwen3-Embedding-0.6B-4bit-DWQ
  - mlx-community/Qwen3-Embedding-4B-4bit-DWQ
```

`ollama:` entries are pulled via `ollama pull`. `llm:` and `embedding:` entries are pulled via the HuggingFace CLI.

## Commands

See [cli.md](cli.md#ai-models) for full command reference.

## Environment

| Variable | Purpose |
|----------|---------|
| `HF_TOKEN` | Loaded from secrets. Required for gated HuggingFace models |
| `HF_HUB_OFFLINE=1` | Prevent HuggingFace network access (offline mode) |
