# rapid-mlx

Local LLM inference server using Apple MLX acceleration.

## Key points

- Config-driven: all instances defined in `config/rapid-mlx.yaml`
- Multi-role: run different models on different ports (`default`, `background`, `think`)
- Single launch script handles all roles via positional argument
- OpenAI-compatible API (`/v1/chat/completions`, `/v1/embeddings`)

## Usage

```bash
lib/services/rapid-mlx/launch [role] [--dry-run]
```

## Files

| File | Purpose |
|------|---------|
| `launch` | Reads config, builds CLI, execs the server |
| `install` | Sets up the Python venv + dependencies |
| `config/rapid-mlx.yaml` | Instance definitions (model, port, features) |

## Docs

See [docs/rapid-mlx.md](../../../docs/rapid-mlx.md) for full configuration reference.
