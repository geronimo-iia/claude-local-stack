# Overmind Supervised Launch

Replace Overmind's broken infinite-restart loop with a per-process supervisor wrapper that implements bounded retries, exponential backoff, and clean exit on crash loop detection.

## Problem

`OVERMIND_AUTO_RESTART=all` causes infinite restart loops when a service crashes on startup (bad config, missing model, port conflict). Overmind has no retry limit or backoff. Current workaround: auto-restart disabled entirely, leaving crashed services dead until manual intervention.

## Design

### Components

```
lib/utils/supervised-launch          ← restart supervisor wrapper
lib/services/*/launch                ← delegate to wrapper instead of exec directly
config/ai-stack.env                  ← OVERMIND_ANY_CAN_DIE=true (services die independently)
```

### Wrapper contract

```bash
supervised-launch <command> [args...]
```

Runs command in a loop with:
- **Max 5 restarts within a 60-second window** — crash loop detection
- **Exponential backoff**: 1s → 2s → 4s → 8s → 16s → capped at 30s
- **Clean exit (code 1)** when crash loop detected — Overmind marks service dead, no loop

### Restart strategy

```
attempt 1 → fail → wait 1s  → restart
attempt 2 → fail → wait 2s  → restart
attempt 3 → fail → wait 4s  → restart
attempt 4 → fail → wait 8s  → restart
attempt 5 → fail → [within 60s window?] → exit 1 (crash loop)
                   [window expired?]     → reset counter, wait 16s, restart
```

Window resets if process ran for > 60s before dying (healthy run, transient failure).

### OVERMIND_ANY_CAN_DIE

With auto-restart off and this wrapper owning restart logic, Overmind must not kill the whole stack when a service exits. Set `OVERMIND_ANY_CAN_DIE=true` in `ai-stack.env` so each service is independent.

### Launch script changes

Before:
```bash
exec headroom proxy --port 8787 ...
```

After:
```bash
exec "${AI_HOME}/lib/utils/supervised-launch" headroom proxy --port 8787 ...
```

`exec` into the wrapper is correct — replaces the shell with the wrapper process, which Overmind tracks. The wrapper owns the restart loop from that point.

### Logging

All supervisor events write to stderr (captured by Overmind):

```
[supervised-launch] starting: headroom proxy --port 8787
[supervised-launch] process exited with code 1 (attempt 2/5)
[supervised-launch] backing off 2s before restart
[supervised-launch] crash loop detected after 5 attempts in 60s — giving up
```

## Operational impact

| Scenario | Before | After |
|---|---|---|
| Service crashes on startup | Infinite restart loop | 5 attempts, then dead |
| Transient failure (network, race) | Infinite restart loop | Recovers with backoff |
| One service dies | Overmind kills all (if not `can-die`) | Other services unaffected |
| Manual restart | `ai-stack restart <svc>` | Same — Overmind restarts wrapper |

## What stays the same

- Procfiles unchanged — they call launch scripts, launch scripts call wrapper
- `ai-stack restart <svc>` still works — Overmind kills wrapper, restarts it fresh
- `ai-stack disable/enable` unchanged
- Profile switching unchanged
