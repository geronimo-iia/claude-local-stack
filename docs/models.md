# Models

Declared in `config/models.yaml`. Downloaded via `ai-models pull`. HuggingFace models stored in `~/.cache/huggingface/hub/`, Ollama models in `~/.ollama/models/`.

## Manifest format

```yaml
ollama:
  - mistral-large

llm:
  - arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8
  - arthurcollet/Qwen3.6-27B-mlx-mxfp8

embedding:
  - mlx-community/bge-m3-mlx-4bit
```

`ollama:` entries are pulled via `ollama pull`. `llm:` and `embedding:` entries are pulled via the HuggingFace CLI.

## Commands

See [cli.md](cli.md#ai-models) for full command reference.

## Environment

| Variable | Purpose |
|----------|---------|
| `HF_TOKEN` | Loaded from secrets. Required for gated HuggingFace models |
| `HF_HUB_OFFLINE=1` | Prevent HuggingFace network access (offline mode) |
