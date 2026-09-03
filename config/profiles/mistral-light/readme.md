# mistral-light profile

Single small model profile. All routes map to Mistral Small 2 (24B) via Ollama. Minimal RAM footprint, fast responses.

Use for: quick tasks, background agents, low-memory situations, testing the LiteLLM routing stack.

## Architecture

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → Ollama (:11434) → mistral-small:24b
```

## Routing

All task types (`background`, `default`, `think`, `longContext`) route to `mistral-small:24b`.

## vs mistral profile

| | mistral-light | mistral |
|--|--|--|
| default/think | mistral-small:24b | mistral-large:123b |
| background | mistral-small:24b | mistral-small:24b |
| Min RAM | ~16 GB | ~128 GB |
