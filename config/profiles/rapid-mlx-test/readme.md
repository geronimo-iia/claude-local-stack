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

| | local (OptiQ-REAP) | rapid-mlx-test (A3B-4bit) |
|---|---|---|
| Size | 13.9 GiB | 19.0 GiB |
| Quant | OptiQ mixed-precision | standard 4bit |
| MTP | no | yes |
| Speed (est.) | ~15 tok/s | ~60 tok/s |
