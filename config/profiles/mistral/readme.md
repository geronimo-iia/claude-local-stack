# Mistral Profile

Single large model profile. Runs Mistral Large 2 (123B) via Ollama with extended context window. Fully local, no cloud dependencies.

## Architecture Flow

```
Claude Code → Headroom (:8787) → CCR (:3456) → Ollama (:11434) → mistral-large:123b  [default / think / longContext]
                                              → Ollama (:11434) → mistral-small:24b   [background]
```

## Services

| Service | Port | Role |
|---------|------|------|
| Ollama | 11434 | Inference backend |
| CCR | 3456 | Router, status line, token tracking |
| Headroom | 8787 | Memory-augmented proxy between Claude Code and CCR |

## Models

| Model | Tag | Quantization | Memory | Role |
|-------|-----|-------------|--------|------|
| Mistral Large 2 | mistral-large:123b | Q4_K_M | ~70 GB | default, think, longContext |
| Mistral Small 4 | mistral-small:24b | Q4_K_M | ~14 GB | background |

Combined footprint: ~84 GB. Requires 128 GB unified memory.

## Routing

| Route | Model | Use case |
|-------|-------|----------|
| `default` | mistral-large:123b | Most coding tasks |
| `think` | mistral-large:123b | Complex reasoning |
| `longContext` | mistral-large:123b | Contexts > 60k tokens |
| `background` | mistral-small:24b | Agentic subtasks, summaries |

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
# 1. Pull models if not already cached
ollama pull mistral-large:123b
ollama pull mistral-small:24b

# 2. Switch to this profile
ai-stack profile mistral
```

## When to Use

- Large codebase sessions requiring 64k–200k context
- Multi-agent workflows with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`
- When Qwen3 multi-instance stack (local profile) is too memory-constrained for long context
- Offline environments where a single capable model is preferable to a tiered setup
