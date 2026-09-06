---
title: "Headroom as Stack Entry Point"
summary: "Why all Claude Code traffic routes through headroom at :8787 regardless of active profile."
status: accepted
last_updated: "2026-09-06"
---

# Headroom as Stack Entry Point

See also: [Components](../components.md) · [Invariants](../invariants.md) · [Troubleshooting](../troubleshooting.md)

## Decision

`ANTHROPIC_BASE_URL=http://localhost:8787` is a constant in `ai-stack.env`. All Claude Code traffic enters the stack through headroom, regardless of which profile is active.

## Context

An alternative design would point Claude Code directly at bifrost (`http://localhost:4000/anthropic`) or at the provider (`https://api.anthropic.com`). Some profiles (e.g. `max-direct`, `bedrock-direct`) already have headroom talk directly to the provider without bifrost in the path — but Claude Code still talks to headroom first.

## Why Headroom First

**Profile switching is invisible to Claude Code.** `ANTHROPIC_BASE_URL` never changes. Switching from `local` to `bedrock` to `max` does not require restarting Claude Code, reconfiguring the IDE, or changing any environment variable outside the stack. Claude Code always dials `localhost:8787`.

**Token compression applies to all profiles.** Headroom's compression (cache control, prompt compression) benefits every backend — local, Bedrock, and Anthropic API. If Claude Code talked directly to bifrost or the provider, compression would require per-profile configuration.

**`ANTHROPIC_API_KEY=local` is a clean sentinel.** The key is never forwarded upstream. Each service in the chain adds its own auth (bifrost injects the real API key or AWS SigV4). The sentinel makes it clear that Claude Code is operating in a managed stack, not directly against Anthropic.

**Single point of observability.** Logs, token savings, and memory all flow through headroom. If the entry point varied by profile, observability would require aggregating across multiple processes.

## Trade-offs

- Headroom is a required service for every profile — if it crashes, Claude Code is fully blocked regardless of whether the backend is healthy
- One extra network hop on the critical path (mitigated by localhost loopback latency being negligible)
