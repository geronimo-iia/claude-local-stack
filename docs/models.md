# Models

## Usage

```bash
ai-models <command> [target...]
ai-models --help
```

| Command | What it does |
|---------|-------------|
| `ai-models pull` | Download all models from manifest |
| `ai-models pull llm` | Download a specific category |
| `ai-models pull mlx-community/bge-m3-4bit` | Download a specific model by repo ID |
| `ai-models list` | Show manifest with download status |

## Manifest

Models are declared in `config/models.yaml` as HuggingFace repo IDs grouped by category:

```yaml
llm:
  - arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8
  - arthurcollet/Qwen3.6-27B-mlx-mxfp8

embedding:
  - mlx-community/bge-m3-4bit
```

## Storage

Models are stored in the default HuggingFace cache (`~/.cache/huggingface/hub/`):

```
~/.cache/huggingface/hub/
├── models--arthurcollet--Qwen3.6-35B-A3B-mlx-mxfp8/
│   ├── blobs/          # content-addressed file storage
│   ├── refs/           # branch → commit mapping
│   └── snapshots/
│       └── <commit>/   # config.json + weights + tokenizer
├── models--mlx-community--bge-m3-4bit/
│   └── ...
```

This approach:
- Deduplicates shared blobs across revisions
- Provides atomic downloads (no partial state)
- Avoids double-storage (no separate cache + local-dir copies)

## Resolving model paths

At serve time, `hf download` is idempotent — it returns the snapshot path instantly if already cached:

```bash
model_path=$(hf download "$repo" --format quiet)
rapid-mlx serve --model "$model_path" ...
```

## Adding a model

1. Add the HuggingFace repo ID to `config/models.yaml` under the appropriate category
2. Run `ai-models pull`

## Environment

- `HF_TOKEN` — loaded automatically from secrets (see [secrets](secrets.md)). Required for gated models
- `HF_HUB_OFFLINE=1` — set this to prevent network access in production

See [repository layout](repository-layout.md) for the full project structure.
