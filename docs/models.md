# Models

Declared in `config/models.yaml`. Downloaded via `ai-models pull`. HuggingFace models stored in `~/.cache/huggingface/hub/`, Ollama models in `~/.ollama/models/`.

## Manifest format

```yaml
ollama:
  - mistral-small:24b                        # Mistral Small 3.1, ~14 GB

rapid-mlx:
  - mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B
  - mlx-community/Qwen3-Embedding-0.6B-4bit-DWQ  # embedding

llm:
  # models pulled via hf download (empty — use rapid-mlx section for MLX models)
```

`ollama:` entries are pulled via `ollama pull`. `rapid-mlx:` entries are pulled via `rapid-mlx pull`. `llm:` entries (if any) are pulled via `hf download`.

## Commands

See [cli.md](cli.md#ai-models) for full command reference.

## Environment

| Variable | Purpose |
|----------|---------|
| `HF_TOKEN` | Loaded from secrets. Required for gated HuggingFace models |
| `HF_HUB_OFFLINE=1` | Prevent HuggingFace network access (offline mode) |
