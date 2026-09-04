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

Swap `model:` in `rapid-mlx.yaml` and `litellm.yaml` to test. Config changes required beyond `model:` are noted per row.

| Model | MLX active | Speed | Config changes vs current | Notes |
| --- | --- | --- | --- | --- |
| `mlx-community/DeepSeek-Coder-V2-Lite-Instruct-4bit-mlx` | ~8 GiB | spec decode ✓ (no MTP) | `tool_call_parser: deepseek_v3`, remove `mtp: true` | MoE; coding-focused; ~100+ tok/s est.; different family |
| ~~`mlx-community/Qwen3.6-27B-4bit`~~          | ~15 GiB  | no MTP        | remove `mtp: true` | pure attention; no drafter; slower than A3B-4bit |
| `mlx-community/Qwen3-Coder-30B-A3B-Instruct-4bit` | ~16 GiB | no spec decode | `tool_call_parser: hermes`, remove `mtp: true` | MoE 30B/3B active; suffix avoid |
| `rapid-mlx/Qwen3.8-Flash-Next-4bit`           | ~103 GiB | ~32 tok/s     | `tool_call_parser: hermes`, remove `mtp: true`, add `--speculative-config '{"method":"mtp"}'` manually | ⚠ experimental; 97.5 GiB download; 148 GiB load peak; 200ms throttle |

### Investigated, not viable

**`mlx-community/Qwen3.8-27B-MTP-4bit`** — crashes on rapid-mlx 0.13.4: `model_type qwen3_5_mtp` not in bundled mlx-lm. Use `rapid-mlx/Qwen3.8-27B-4bit-MTP-MLX` (the curated alias) instead. That model is hybrid arch (linear-attention/Mamba); default spec decode is off for hybrid, but MTP sidecar is available via explicit `--speculative-config`. Estimated ~41 tok/s — slower than A3B-4bit at 73 tok/s, so not a priority.
