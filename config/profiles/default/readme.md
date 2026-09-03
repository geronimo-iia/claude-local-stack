# Default Profile

Balanced single-model profile for general coding assistance. Runs everything locally on Apple Silicon with no cloud dependencies.

## Architecture Flow

```
Claude Code → Headroom (:8787) → CCR (:3456) → rapid-mlx (:8000) → Qwen3.6-35B-A3B (MLX)
```

## Services

| Service | Port | Role |
|---------|------|------|
| rapid-mlx | 8000 | Local LLM inference (MLX backend) |
| CCR | 3456 | Request routing, status line, token tracking |
| Headroom | 8787 | Memory-augmented proxy between Claude Code and CCR |

## Model

**mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B** — 35B MoE (~19B effective), OptiQ 4bit quantization. Fits comfortably in 32GB unified memory with room for embedding model alongside.

Key inference flags:
- `paged_cache: true` — efficient KV cache for long sequences
- `mtp: true` — multi-token prediction for faster generation
- `no_thinking: true` — skip CoT overhead, direct responses
- `tool_call_parser: qwen3_coder` — structured tool-use output

## Routing

All CCR routes (`default`, `background`, `think`, `longContext`) point to the same model instance. No tier differentiation — simplicity over optimization.

`longContextThreshold: 60000` tokens triggers the longContext route (same destination in this profile).

## When to Use

- Day-to-day coding tasks
- Single-project focus (one model instance, no contention)
- Offline / air-gapped environments
