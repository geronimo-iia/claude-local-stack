# AGENTS.md — claude-local-stack

Local AI stack for Claude Code on Apple Silicon (macOS only).

## Architecture

```
Claude Code → Headroom (:8787) → CCR (:3456) → rapid-mlx / Ollama / Bedrock
```

Active profile controls which backend is wired in.

## Key paths

| Path | Purpose |
|------|---------|
| `config/ai-stack.env` | All env vars (ports, paths, flags) |
| `config/Procfile` | Active service definitions for overmind |
| `config/profiles/` | Profile configs (ccr.json, Procfile, rapid-mlx.yaml) |
| `config/.active-profile` | Runtime state — gitignored |
| `bin/ai-stack` | Main CLI (start/stop/profile/check/install/enable/disable…) |
| `bin/ai-install` | Component installer (sources `lib/*/install`) |
| `bin/ai-secrets` | SOPS+age secrets manager |
| `bin/ai-models` | HuggingFace model manifest manager |
| `lib/services/` | Daemons and installable tools managed by overmind or standalone |
| `lib/plugins/` | Claude Code plugins (not daemons) |
| `lib/setup/` | One-shot bootstrap scripts (prerequisites, runtimes, tooling) |
| `config/base-services.yaml` | Universal deps checked before any profile (claude-code, superpowers, overmind) |
| `secrets/api-keys.sops.yaml` | Encrypted API keys (never commit unencrypted) |
| `logs/` | Runtime output — gitignored |

## Component conventions

Every component (`lib/services/<name>/` or `lib/plugins/<name>/`) must have:

- `install` — idempotent zsh script, handles `install` (default), `upgrade`, `remove`, `check`
- `priority` — optional integer controlling install order (default: 50)
- `readme.md` — optional description

Services additionally need:
- `launch` — starts the daemon, typically via `lib/utils/supervised-launch`

### install script pattern

```zsh
#!/bin/zsh
set -euo pipefail

[[ -z "${AI_HOME:-}" ]] && source "$(dirname "$0")/../../../config/ai-stack.env"

case "${1:-install}" in
  remove)   ... ;;
  upgrade)  ... ;;
  install)  ... ;;
  check)
    command -v <binary> &>/dev/null && echo "  ✓ <name>" || { echo "  ✗ <name>"; exit 1; }
    # plugins: claude plugin list 2>/dev/null | grep -q "<plugin-id>" && ... || { ...; exit 1; }
    ;;
  *)
    echo "Unsupported command: ${1:-install}. Use: install (default), upgrade, remove, or check." >&2
    exit 1
    ;;
esac
```

Scripts source `ai-stack.env` only if `AI_HOME` is not already set (already-exported env wins).

## Profiles

A profile is `config/profiles/<name>/` containing:
- `ccr.json` → copied to `~/.claude-code-router/config.json` on activation
- `Procfile` → copied to `config/Procfile`
- `rapid-mlx.yaml` → copied to `config/rapid-mlx.yaml` (omit for cloud/ollama profiles)
- `services.yaml` → dep manifest: `install:` (services), `plugins:`, `mcp:`, `check:` sections

Switching profile: `ai-stack profile <name>` — stops stack, copies files, restarts.

`enable`/`disable` modify the **active** Procfile only — profile switch resets it.

## Secrets

- Encrypted with SOPS + age, key at `secrets/age-key.txt` (gitignored)
- Never put API keys in env files, settings.json, or any committed file
- Read/write via `ai-secrets edit` / `ai-secrets get <key>`
- `ai-stack start` auto-decrypts and exports secrets before launching services
- `ANTHROPIC_API_KEY=local` is a sentinel — Headroom intercepts at :8787, no real key forwarded

## Environment

- Runtimes managed by asdf (Python 3.12, Node 22 LTS, Rust) — see `.tool-versions`
- Python packages: `uv tool install` (tools) or `uv venv` (per-service venvs)
- Node packages: `npm install -g` or local installs in service dirs
- macOS packages: Homebrew
- `ai-stack shell` opens a subshell with full env + secrets loaded

## Adding a service

1. `mkdir lib/services/<name>`
2. Write `install` (idempotent, handle install/upgrade/remove/check)
3. Write `launch` (exec the daemon via `supervised-launch` if long-running)
4. Add entry to relevant profile `Procfile`s
5. Add to relevant profile `services.yaml` `install:` section (or `config/base-services.yaml` if universal)
6. Test: `ai-stack service install <name>` then `ai-stack service check <name>` then `ai-stack enable <name>`

## Adding a plugin

1. `mkdir lib/plugins/<name>`
2. Write `install` (handle install/upgrade/remove/check)
3. No `launch` — plugins are not daemons
4. Add to relevant profile `services.yaml` `plugins:` section (or `config/base-services.yaml` if universal)
5. Test: `ai-stack plugin install <name>`

## CLI quick ref

```bash
ai-stack start|stop|restart [svc]     # lifecycle
ai-stack status                        # running processes
ai-stack profile [name]                # show or switch profile
ai-stack check [profile]               # dep report for active (or named) profile
ai-stack install [profile]             # install all missing deps
ai-stack enable|disable <svc...>       # toggle services in active Procfile
ai-stack logs [svc]                    # stream logs
ai-stack shell                         # subshell with env + secrets

ai-install [name...]                   # install components (all if no args)
ai-install --list                      # show available components

ai-secrets init|edit|get|show|rotate   # secrets management
ai-models pull|list                    # model management
```

## What not to do

- Don't hardcode `$HOME` or absolute paths — always use `$AI_HOME` (set by `ai-stack.env`)
- Don't run `ai-stack` commands outside an activated profile — Procfile may be stale
- Don't edit `config/Procfile` directly — it's overwritten on profile switch; edit the profile source
- Don't commit `secrets/age-key.txt`, `secrets/api-keys.sops.yaml`, `config/.active-profile`, or `logs/`
- Don't assume services are running — check `ai-stack status` first
