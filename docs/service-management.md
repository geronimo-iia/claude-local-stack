# Service Management

Services are managed by [overmind](https://github.com/DarthSim/overmind) — a Procfile-based process manager with per-service control and tmux-backed output.

See [configuration](configuration.md) for Procfile format, overmind settings, and runtime overrides.

## Commands

| Command | What it does |
|---------|--------------|
| `ai-stack start` | Start all enabled services (daemonized) |
| `ai-stack stop` | Stop all services |
| `ai-stack restart` | Restart all services |
| `ai-stack restart <svc>` | Restart one service |
| `ai-stack status` | Show running processes |
| `ai-stack enable [svc...]` | Enable services (all if none specified) |
| `ai-stack disable [svc...]` | Disable services (all if none specified) |
| `ai-stack logs` | Stream all output |
| `ai-stack logs <svc>` | Attach to one service (tmux pane) |

## Enable / Disable

Toggles a `#` prefix on the matching line in the Procfile. If the stack is running, it auto-restarts to apply the change.

```bash
ai-stack disable headroom     # comments the line, restarts stack
ai-stack enable headroom      # uncomments the line, restarts stack
ai-stack enable               # enable all services
ai-stack disable              # disable all services
```

To batch changes without intermediate restarts:

```bash
ai-stack stop
ai-stack enable rapid-mlx
ai-stack disable headroom
ai-stack start
```

## Attach to live output

```bash
ai-stack logs rapid-mlx
```

Detach: `Ctrl+B` then `D`.

## Direct overmind usage

```bash
export OVERMIND_SOCKET="${TMPDIR:-/tmp}/ai-stack.overmind.sock"

overmind ps
overmind restart ccr
overmind stop headroom
overmind connect rapid-mlx
overmind quit
```
