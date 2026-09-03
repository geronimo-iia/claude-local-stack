# Mistral Profile

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

## Context Window

Start Ollama with flash attention and KV-cache quantization to maximize available context:

```bash
# 200k context — recommended for large codebases and multi-agent sessions
OLLAMA_FLASH_ATTENTION=1 \
OLLAMA_KV_CACHE_TYPE=q8_0 \
OLLAMA_CONTEXT_LENGTH=200000 \
ollama serve
```

Memory budget at 200k context on 128 GB (large model active):

| Item | Memory |
|------|--------|
| mistral-large:123b weights | ~70 GB |
| mistral-small:24b weights | ~14 GB |
| KV-cache (FA + q8_0) | ~12–15 GB |
| OS + system | ~10 GB |
| **Total** | **~106–109 GB** |

## Multi-Agent Concurrency

Add to `~/.zshrc` or `config/ai-stack.env`:

```bash
export OLLAMA_NUM_PARALLEL=3       # 3 concurrent agent channels
export OLLAMA_MAX_LOADED_MODELS=2  # optional: keep a second smaller model loaded
```

## Activation

```bash
# 1. Pull model if not already cached
ollama pull mistral-large:123b-instruct-2411-q4_K_M

# 2. Switch to this profile
ai-stack profile mistral
```

## When to Use

- Large codebase sessions requiring 64k–200k context
- Multi-agent workflows with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- When Qwen3 multi-instance stack (local profile) is too memory-constrained for long context
- Offline environments where a single capable model is preferable to a tiered setup
