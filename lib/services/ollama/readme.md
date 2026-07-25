# ollama service

Runs `ollama serve` with extended context window and memory optimizations for Apple Silicon.

## Environment Variables

Configured via `config/ai-stack.env` — all have defaults baked into the launch script:

| Variable | Default | Description |
|----------|---------|-------------|
| `OLLAMA_FLASH_ATTENTION` | `1` | Halves KV-cache memory on Apple Silicon |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Quantizes KV-cache, halves footprint again |
| `OLLAMA_CONTEXT_LENGTH` | `200000` | Default context window for all models |
| `OLLAMA_NUM_PARALLEL` | `3` | Concurrent agent request channels |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Models kept in memory simultaneously |

Override any of these in `config/ai-stack.env`.

## Models

Pull models separately — not managed by install:

```bash
ollama pull mistral-large
```

## Used By

- `config/profiles/mistral/`
