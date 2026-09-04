# rapid-mlx-test Profile

Test profile comparing `mlx-community/Qwen3.6-35B-A3B-4bit` (standard 4bit + MTP) against the `local` profile's OptiQ-4bit-REAP-19B.

## Architecture Flow

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → rapid-mlx (:8000) → Qwen3.6-35B-A3B-4bit (MLX)
```

## Model

**mlx-community/Qwen3.6-35B-A3B-4bit** — same MoE architecture as `local`, standard 4bit quantization (~19 GiB vs 13.9 GiB for OptiQ). MTP sidecar enabled for speculative decoding.

Key inference flags:
- `mtp: true` — multi-token prediction sidecar (~30-40% throughput gain)
- `no_thinking: true` — skip CoT overhead
- `tool_call_parser: qwen3_coder_xml` — structured tool-use output
- `continuous-batching` — efficient concurrent request handling

## vs local profile

|                                   | local (OptiQ-REAP)    | rapid-mlx-test (A3B-4bit) |
| --------------------------------- | --------------------- | ------------------------- |
| Size                              | 13.9 GiB              | 19.0 GiB                  |
| MLX active                        | ~14 GiB               | ~23 GiB                   |
| Quant                             | OptiQ mixed-precision | standard 4bit             |
| MTP                               | no                    | yes                       |
| Speed (measured, 192 GB M3 Ultra) | ~15.5 tok/s           | **~73 tok/s**             |

## Other models to evaluate

Swap `model:` in `rapid-mlx.yaml` and `litellm.yaml` to test:

| Model                                         | MLX active | MTP decode @8K       | Notes                                               |
| --------------------------------------------- | ---------- | -------------------- | --------------------------------------------------- |
| `mlx-community/Qwen3.6-27B-4bit`              | ~15 GiB    | ~50 tok/s (est.)     | dense 27B, MTP-capable                              |
| `mlx-community/Qwen3-Coder-30B-Instruct-4bit` | ~16 GiB    | unknown (no MTP)     | coding-focused fine-tune                            |
| `rapid-mlx/Qwen3.8-Flash-Next-4bit`           | ~103 GiB   | ~32 tok/s (+41% MTP) | QSA hybrid arch; requires 192 GB; 148 GiB load peak |

### Investigated, not viable

**`mlx-community/Qwen3.8-27B-MTP-4bit`** — crashes on rapid-mlx 0.13.4: `model_type qwen3_5_mtp` not in bundled mlx-lm. The correct rapid-mlx alias is `rapid-mlx/Qwen3.8-27B-4bit-MTP-MLX`, but that model is hybrid arch (linear-attention/Mamba), MTP disabled for hybrid, ~41 tok/s estimated — slower than A3B-4bit at 73 tok/s.
