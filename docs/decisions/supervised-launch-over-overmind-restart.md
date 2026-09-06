---
title: "supervised-launch over Overmind Auto-Restart"
summary: "Why crash recovery uses a custom wrapper rather than Overmind's built-in auto-restart."
status: accepted
last_updated: "2026-09-06"
---

# supervised-launch over Overmind Auto-Restart

See also: [Overmind](../overmind.md) · [Invariants](../invariants.md)

## Decision

All service launch scripts delegate to `lib/utils/supervised-launch` for crash recovery. Overmind's `OVERMIND_AUTO_RESTART` is deliberately not set.

## Context

Overmind supports automatic process restart via `OVERMIND_AUTO_RESTART=all`. The simpler approach would be to enable it and let overmind handle crashes.

## Why Not Overmind Auto-Restart

**Overmind auto-restart is unbounded.** A service that crashes immediately on startup will be restarted indefinitely, consuming CPU, filling logs, and masking the underlying failure. There is no crash loop detection.

**Crash loops are silent.** Overmind does not distinguish a transient failure (recoverable) from a permanent failure (broken config, missing binary, port conflict). Both look identical in `overmind ps`.

**`OVERMIND_ANY_CAN_DIE=true` is already set.** One dead service does not stop others. Without bounded restart, a crash-looping service becomes permanent background noise rather than a visible failure requiring investigation.

## Why supervised-launch

The wrapper enforces a contract: up to 5 restarts within a 60-second window, exponential backoff (1s → 2s → 4s → 8s → 16s, capped at 30s), clean exit on crash loop detection. After 5 rapid crashes, the service stays dead — `ai-stack status` shows it clearly, no noise.

The counter resets if the process ran longer than 60 seconds — a transient failure (memory spike, timeout) is correctly treated as recoverable, not a crash loop.

## Trade-offs

- Each launch script must explicitly `exec` into `supervised-launch` — forgetting it means no crash recovery
- Restart configuration (attempts, window) is hardcoded in the wrapper; not configurable per-service without editing the script
