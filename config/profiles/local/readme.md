# Default Profile

Balanced single-model profile for general coding assistance. Runs everything locally on Apple Silicon with no cloud dependencies.

## Architecture Flow

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → rapid-mlx (:8000) → Qwen3.6-35B-A3B (MLX)
```

## Services

| Service | Port | Role |
|---------|------|------|
| rapid-mlx | 8000 | Local LLM inference (MLX backend) |
| LiteLLM | 4000 | Model routing proxy |
| Headroom | 8787 | Memory-augmented proxy between Claude Code and LiteLLM |

## Model

**mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B** — 35B MoE (~19B effective), OptiQ 4bit quantization. Fits comfortably in 32GB unified memory with room for embedding model alongside.

Key inference flags:
- `no_thinking: true` — skip CoT overhead, direct responses
- `suffix_decoding: true` — faster fill-in-the-middle completions
- `tool_call_parser: qwen3_coder_xml` — structured tool-use output
- `continuous-batching` — efficient concurrent request handling

## Performance

~15.5 tok/s end-to-end (TTFT included) on Apple M3 Max 128GB. Expected for a 35B model on consumer hardware via MLX. Claude Sonnet API is ~60–80 tok/s by comparison.

## Routing

All model name patterns (`claude-haiku*`, `claude-sonnet*`, `claude-opus*`, `*`) route to the same Qwen3.6-35B instance. No tier differentiation — simplicity over optimization.

## When to Use

- Day-to-day coding tasks
- Single-project focus (one model instance, no contention)
- Offline / air-gapped environments
