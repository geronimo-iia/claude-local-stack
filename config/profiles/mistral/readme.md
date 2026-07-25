# Mistral Profile

Single large model profile. Runs Mistral Large 2 (123B) via Ollama with extended context window. Fully local, no cloud dependencies.

## Architecture Flow

```
Claude Code → Headroom (:8787) → CCR (:3456) → Ollama (:11434) → Mistral Large 2 (123B)
```

## Services

| Service | Port | Role |
|---------|------|------|
| Ollama | 11434 | Inference backend |
| CCR | 3456 | Router, status line, token tracking |
| Headroom | 8787 | Memory-augmented proxy between Claude Code and CCR |

## Model

| Model | Quantization | Memory footprint |
|-------|-------------|-----------------|
| mistral-large | Q4_K_M | ~70 GB |

Requires 128 GB unified memory. Leaves ~58 GB free for OS, context window, and agents.

## Context Window

Start Ollama with flash attention and KV-cache quantization to maximize available context:

```bash
# 200k context — recommended for large codebases and multi-agent sessions
OLLAMA_FLASH_ATTENTION=1 \
OLLAMA_KV_CACHE_TYPE=q8_0 \
OLLAMA_CONTEXT_LENGTH=200000 \
ollama serve
```

Memory budget at 200k context on 128 GB:

| Item | Memory |
|------|--------|
| Model weights (Q4_K_M) | ~70 GB |
| KV-cache (FA + q8_0) | ~12–15 GB |
| OS + system | ~10 GB |
| **Total** | **~92–95 GB** |

## Multi-Agent Concurrency

Add to `~/.zshrc` or `config/ai-stack.env`:

```bash
export OLLAMA_NUM_PARALLEL=3       # 3 concurrent agent channels
export OLLAMA_MAX_LOADED_MODELS=2  # optional: keep a second smaller model loaded
```

## Activation

```bash
# 1. Pull the model if not already cached
ollama pull mistral-large

# 2. Switch to this profile
ai-stack profile mistral
```

## When to Use

- Large codebase sessions requiring 64k–200k context
- Multi-agent workflows with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- When Qwen3 multi-instance stack (local profile) is too memory-constrained for long context
- Offline environments where a single capable model is preferable to a tiered setup
