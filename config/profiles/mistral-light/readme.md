# mistral-light profile

> **Not usable for interactive Claude Code sessions.**
> Claude Code sends 20k+ token contexts per request. `mistral-small:24b` on Ollama takes 3+ minutes
> to respond even to a simple "hello". Use the `mistral` profile (large model) or `multi` profile instead.

Single small model profile. All routes map to Mistral Small 2 (24B) via Ollama. Minimal RAM footprint.

Use for: batch/offline tasks only — not interactive use.

## Architecture

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → Ollama (:11434) → mistral-small:24b
```

## Routing

All task types (`background`, `default`, `think`, `longContext`) route to `mistral-small:24b`.

## Context window

`mistral-small:24b` defaults to 2048 tokens in Ollama. All routes set `num_ctx: 32768` via `extra_body`
to avoid silent truncation on longer inputs. Pass directly as `litellm_params.num_ctx` — LiteLLM maps it to `options.num_ctx` in the Ollama request.

## vs mistral profile

| | mistral-light | mistral |
|--|--|--|
| default/think | mistral-small:24b | mistral-large:123b |
| background | mistral-small:24b | mistral-small:24b |
| Min RAM | ~16 GB | ~128 GB |
