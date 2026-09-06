---
title: "Profile-Driven Service Install"
summary: "Why ai-install is bootstrap-only and service installation is delegated to ai-stack install."
status: accepted
last_updated: "2026-09-06"
---

# Profile-Driven Service Install

## Decision

`ai-install` bootstraps the machine only (prerequisites, runtimes, tooling). Service and plugin installation is driven by `ai-stack install`, which reads `base-services.yaml` + the active profile's `services.yaml`.

## Context

The original `ai-install` walked all `lib/services/*/install` scripts sorted by priority, installing every service regardless of the active profile. This was inherited from a simpler single-profile setup.

## Why Profile-Driven

**Don't install what you don't need.** The `max` profile requires headroom and bifrost — it does not need ollama, rapid-mlx, or voicemode. Installing everything wastes time, disk, and introduces services that may fail their install check on a machine that lacks the hardware or accounts for them.

**`services.yaml` is the authoritative dep list per profile.** Each profile already declares exactly what it needs. Reusing this for install means the install list and the runtime list are always in sync — there is one source of truth.

**`ai-install` is a one-time operation.** Bootstrap runs once on a new machine. Service install runs per profile, potentially multiple times as profiles change. Keeping them separate makes the intent clear.

## Trade-offs

- First-time setup requires two commands (`ai-install` then `ai-stack profile <name> && ai-stack install`) instead of one
- If `AI_STACK_AUTO_INSTALL=true`, profile switch triggers `ai-stack install` automatically — the two-step is invisible in practice
