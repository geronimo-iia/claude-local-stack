# Overmind

Process manager for ai-stack services. Procfile-based, per-service control, tmux-backed output.

## ai-stack commands

| Command                  | What it does                                       |
| ------------------------ | -------------------------------------------------- |
| `ai-stack start`         | Start all enabled services (daemonized)            |
| `ai-stack stop`          | Stop all services                                  |
| `ai-stack restart [svc]` | Restart all or one service                         |
| `ai-stack status`        | Show running processes                             |
| `ai-stack enable <svc>`  | Uncomment service in Procfile, restart if running  |
| `ai-stack disable <svc>` | Comment service in Procfile, restart if running    |
| `ai-stack logs [svc]`    | Stream all output, or attach to one service (tmux) |

Detach from tmux pane: `Ctrl+B` then `D`.

## Environment configuration

Set in `config/ai-stack.env`:

```bash
# Service definitions file
OVERMIND_PROCFILE="${AI_HOME}/config/Procfile"

# Runtime socket (ephemeral)
OVERMIND_SOCKET="${TMPDIR:-/tmp}/ai-stack.overmind.sock"

# Allow individual services to die without stopping the whole stack
OVERMIND_ANY_CAN_DIE="true"

# Auto-restart disabled — supervised-launch wrapper handles restarts
# OVERMIND_AUTO_RESTART="all"
```

## Procfile format

Each line: `name: command`. Comment with `#` to disable.

```procfile
bifrost:  ${AI_HOME}/lib/services/bifrost/launch
headroom: ${AI_HOME}/lib/services/headroom/launch-bifrost
rapid-mlx-default: ${AI_HOME}/lib/services/rapid-mlx/launch default
```

Active Procfile is copied from the current profile (`config/profiles/<name>/Procfile`).

## Direct overmind usage

```bash
export OVERMIND_SOCKET="${TMPDIR:-/tmp}/ai-stack.overmind.sock"

overmind ps
overmind restart bifrost
overmind stop headroom
overmind connect rapid-mlx-default    # attach to live output
overmind quit
```

## Supervised launch

`lib/utils/supervised-launch` wraps each service with bounded restart logic:

- Max 5 restarts within a 60-second window
- Exponential backoff: 1s → 2s → 4s → 8s → 16s (capped at 30s)
- Clean exit on crash loop detection — service stays dead, other services unaffected

Launch scripts delegate to the wrapper:

```bash
exec "${AI_HOME}/lib/utils/supervised-launch" headroom proxy --port 8787 ...
```

`OVERMIND_ANY_CAN_DIE=true` ensures one crashed service doesn't kill the whole stack.

| Scenario          | Behavior                               |
| ----------------- | -------------------------------------- |
| Crash on startup  | 5 attempts with backoff, then dead     |
| Transient failure | Recovers with backoff                  |
| One service dies  | Other services unaffected              |
| Manual restart    | `ai-stack restart <svc>` — fresh start |
