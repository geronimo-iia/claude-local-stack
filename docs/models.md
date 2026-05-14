# Models

Declared in `config/models.yaml`. Downloaded via `ai-models pull`. Stored in HuggingFace cache (`~/.cache/huggingface/hub/`).

## Manifest format

```yaml
llm:
  - arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8
  - arthurcollet/Qwen3.6-27B-mlx-mxfp8
  - mlx-community/Qwen3-235B-A22B-4bit

embedding:
  - mlx-community/bge-m3-mlx-4bit
```

## Commands

See [cli.md](cli.md#ai-models) for full command reference.

## Environment

| Variable | Purpose |
|----------|---------|
| `HF_TOKEN` | Loaded from secrets. Required for gated models |
| `HF_HUB_OFFLINE=1` | Prevent network access (offline mode) |
