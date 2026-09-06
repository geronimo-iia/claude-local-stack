---
title: "Per-Service Env Layering"
summary: "Why service-specific env vars are split across three layers instead of one global env file."
status: accepted
last_updated: "2026-09-06"
---

# Per-Service Env Layering

See also: [Env vars reference](../README.md#environment-variables) · [Profiles](../profiles.md) · [Invariants](../invariants.md)

## Decision

Env vars are split across three layers loaded in order:

1. `config/ai-stack.env` — stack topology (ports, paths, flags) inherited by all processes
2. `lib/services/<svc>/default.env` — service-local defaults, sourced only by that service's launch script
3. `config/profiles/<profile>/<svc>.env` — profile-specific overrides (optional, gitignored)

The `lib/utils/load-service-env` helper sources layers 2 and 3 automatically.

## Context

Previously all vars lived in `config/ai-stack.env`. This meant every process inherited `OLLAMA_*`, `AWS_ACCESS_KEY_ID`, `HEADROOM_*`, etc. regardless of whether it needed them. Adding a new profile required editing the global file and adding conditional logic.

## Why This Approach

**Least-privilege env.** AWS credentials are only present in the process that needs them (bifrost on the `bedrock` profile). Ollama tuning vars are only present in the ollama process. Nothing leaks across services.

**Profile customization without touching global state.** A profile can override `HEADROOM_WORKERS=4` for its headroom instance without affecting other profiles or other services.

**No conditional logic in `ai-stack.env`.** The global file stays topology-only — ports and paths that every process genuinely needs. No `if [[ "$profile" == "bedrock" ]]` branches.

## Trade-offs

- Launch scripts must explicitly call `load-service-env` — forgetting it means the service starts with missing vars (silent failure, not an error)
- Slightly more files to track per service
- Profile env files are gitignored — a new machine needs them recreated (mitigated by `docs/profiles.md` documenting the required vars)
