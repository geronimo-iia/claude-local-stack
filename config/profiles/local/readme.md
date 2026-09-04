# Local Profile

Balanced single-model profile for general coding assistance. Runs everything locally on Apple Silicon with no cloud dependencies.

## Architecture Flow

```
Claude Code → Headroom (:8787) → Bifrost (:4000) → rapid-mlx (:8000) → Qwen3.6-35B-A3B-4bit (MLX)
```

## Services

| Service | Port | Role |
|---------|------|------|
| rapid-mlx | 8000 | Local LLM inference (MLX backend) |
| Bifrost | 4000 | Anthropic→OpenAI conversion + routing |
| Headroom | 8787 | Token compression proxy |

## Model

**mlx-community/Qwen3.6-35B-A3B-4bit** — 35B MoE (~3.6B effective), standard 4bit quantization, MTP sidecar for speculative decoding. Quality-tested 2026-09-04: trustworthy for daily Rust (clean tool calls, real bug found, no API hallucinations, 127 tests passed).

Key inference flags:
- `mtp: true` — multi-token prediction sidecar (~30-40% throughput gain)
- `no_thinking: true` — skip CoT overhead, direct responses
- `suffix_decoding: true` — faster fill-in-the-middle completions
- `paged_cache: true` — paged KV cache for long contexts
- `tool_call_parser: qwen3_coder` — structured tool-use output
- `continuous-batching` — efficient concurrent request handling

## Performance

~73 tok/s on Apple M3 Ultra 192GB (MTP enabled). Previous model (OptiQ-4bit-REAP-19B) ran at ~15.5 tok/s on the same hardware — A3B-4bit is ~5x faster at the cost of mixed-precision quantization.

## Routing

All model names (`claude-haiku*`, `claude-sonnet*`, `claude-opus*`, `*`) route to the same Qwen3.6-35B instance via bifrost aliases. No tier differentiation.

## When to Use

- Day-to-day coding tasks
- Single-project focus (one model instance, no contention)
- Offline / air-gapped environments
