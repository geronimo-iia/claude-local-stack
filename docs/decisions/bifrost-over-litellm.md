---
title: "Bifrost over LiteLLM"
summary: "Why bifrost replaced LiteLLM as the routing layer for all profiles."
status: accepted
last_updated: "2026-09-06"
---

# Bifrost over LiteLLM

## Decision

Bifrost (`@maximhq/bifrost`) replaced LiteLLM as the multi-provider routing gateway. LiteLLM has been removed from the stack entirely.

## Context

LiteLLM was used to bridge Claude Code's Anthropic message format to OpenAI-compatible local backends (rapid-mlx, Ollama). It handled model aliasing and provider fallback via a YAML config.

## Why Not LiteLLM

**LiteLLM stripped `tools` from requests before forwarding to OpenAI-compatible backends.** Claude Code uses tool use extensively (file read/write, bash, search). With LiteLLM in the path, tool calls silently disappeared — the local model received a plain text conversation with no tool schema. This broke the agentic loop entirely for local profiles.

Additionally:
- LiteLLM required a Python venv, adding startup time and a fragile dependency
- Config was a separate YAML file per profile with its own format
- No native Bedrock SigV4 support — required custom wrappers

## Why Bifrost

Bifrost correctly forwards the full Anthropic message shape (including `tools`) to OpenAI-compatible backends. It is distributed as a Go binary via npm, starts in under a second, and uses a single `config.json` that works for both local and cloud profiles.

Additional benefits: native Bedrock SigV4 auth, weight-based key load balancing, model aliasing, semantic cache plugin, MCP aggregation (future).

## Trade-offs

|                     | LiteLLM                | Bifrost                          |
| ------------------- | ---------------------- | -------------------------------- |
| Tool use forwarding | Broken (strips tools)  | Correct                          |
| Startup time        | ~3s (Python)           | <1s (Go binary)                  |
| Bedrock SigV4       | Manual wrapper         | Native                           |
| Config format       | Per-profile YAML       | Single config.json with env refs |
| Ecosystem maturity  | Large, well-documented | Smaller, actively developed      |
