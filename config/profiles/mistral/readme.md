# Mistral Profile

> **Not suitable for interactive Claude Code sessions.**
> Loading 73 GB into GPU + prefilling 20k+ token contexts takes 2–3 minutes per response.
> Use the `local` profile (rapid-mlx + Qwen3.6) for interactive work instead.

Single large model profile. All routes map to Mistral Large 2 (123B) via Ollama. Fully local, no cloud dependencies.

## Architecture Flow

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → Ollama (:11434) → mistral-large:123b  [all tiers]
```

## Services

| Service | Port | Role |
|---------|------|------|
| Ollama | 11434 | Inference backend |
| LiteLLM | 4000 | Proxy, model routing |
| Headroom | 8787 | Memory-augmented proxy between Claude Code and LiteLLM |

## Models

| Model | Tag | Quantization | Memory | Role |
|-------|-----|-------------|--------|------|
| Mistral Large 2 | mistral-large:123b-instruct-2411-q4_K_M | Q4_K_M | ~73 GB | all tiers |

## Routing

All task types (`claude-haiku*`, `claude-sonnet*`, `claude-opus*`, catch-all) route to `mistral-large:123b-instruct-2411-q4_K_M` with `num_ctx: 131072`, `num_gpu: 99`, `num_keep: -1`.

## Performance

Measured on Apple Silicon with 128 GB unified memory:

- First request: 2–3 min (model load into GPU + prefill)
- Subsequent requests: 30–90s depending on context size
- Generation speed: ~4–8 tok/s

## Context Window

Start Ollama with flash attention and KV-cache quantization to maximize available context:

```bash
OLLAMA_FLASH_ATTENTION=1 \
OLLAMA_KV_CACHE_TYPE=q8_0 \
ollama serve
```

## Activation

```bash
# 1. Pull model if not already cached
ollama pull mistral-large:123b-instruct-2411-q4_K_M

# 2. Switch to this profile
ai-stack profile mistral
```

## When to Use

- Air-gapped environments with no cloud access
- Sensitive codebases that must not leave the machine
- Batch/offline tasks where latency is acceptable
