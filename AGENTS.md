# AGENTS.md — claude-local-stack

Local AI stack for Claude Code on Apple Silicon (macOS only).

## Architecture

```
Claude Code → Headroom (:8787) → Bifrost (:4000) → rapid-mlx / Ollama / Bedrock
```

Active profile controls which backend is wired in. Some profiles bypass bifrost (headroom talks directly to the provider).

## Key paths

| Path | Purpose |
|------|---------|
| `config/ai-stack.env` | Stack topology vars (ports, paths, flags) — sourced first by all scripts |
| `config/Procfile` | Active service definitions for overmind — copied from active profile |
| `config/.active-profile` | Runtime state — gitignored |
| `config/profiles/` | Profile configs (Procfile, bifrost/, rapid-mlx.yaml, services.yaml, *.env) |
| `config/.bifrost/config.json` | Active bifrost config — copied from profile on switch |
| `config/.env` | Local machine overrides — gitignored, sourced last by ai-stack.env |
| `lib/services/` | Daemons and installable tools managed by overmind or standalone |
| `lib/services/<svc>/default.env` | Service-local env defaults (loaded by load-service-env) |
| `lib/plugins/` | Claude Code plugins (not daemons) |
| `lib/setup/` | One-shot bootstrap scripts (prerequisites, runtimes, tooling) |
| `lib/utils/load-service-env` | Env layering helper — sources default.env then profile override |
| `lib/utils/supervised-launch` | Restart wrapper (5 attempts / 60s window, exponential backoff) |
| `config/base-services.yaml` | Universal deps checked before any profile (claude-code, superpowers, overmind) |
| `bin/ai-stack` | Main CLI |
| `bin/ai-install` | Machine bootstrap only (prerequisites, runtimes, tooling) |
| `bin/ai-secrets` | SOPS+age secrets manager |
| `bin/ai-models` | HuggingFace model manifest manager |
| `secrets/api-keys.sops.yaml` | Encrypted API keys — never commit unencrypted |
| `logs/` | Runtime output — gitignored |

## Env layering

Three layers, loaded in order (later overrides earlier):

1. `config/ai-stack.env` — topology constants, all processes inherit
2. `lib/services/<svc>/default.env` — service-local defaults (loaded by `load-service-env`)
3. `config/profiles/<profile>/<svc>.env` — profile-specific overrides (optional)

Launch scripts must source both layers before starting the daemon:

```zsh
source "$(dirname "$0")/../../../config/ai-stack.env"
source "${AI_HOME}/lib/utils/load-service-env" "<service-name>"
exec "${AI_HOME}/lib/utils/supervised-launch" <binary> [args...]
```

## Component conventions

Every component (`lib/services/<name>/` or `lib/plugins/<name>/`) must have:

- `install` — idempotent zsh script, handles `install` (default), `upgrade`, `remove`, `check`
- `priority` — optional integer controlling install order (default: 50)
- `readme.md` — optional description

Services additionally need:
- `launch` — starts the daemon via `supervised-launch`
- `default.env` — optional, service-local env defaults

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
    ;;
  *)
    echo "Unsupported command: ${1:-install}. Use: install (default), upgrade, remove, or check." >&2
    exit 1
    ;;
esac
```

## Profiles

A profile is `config/profiles/<name>/` containing:
- `bifrost/config.json` → copied to `config/.bifrost/config.json` on activation (bifrost profiles only)
- `Procfile` → copied to `config/Procfile`
- `rapid-mlx.yaml` → copied to `config/rapid-mlx.yaml` (rapid-mlx profiles only)
- `services.yaml` → dep manifest: `install:`, `plugins:`, `mcp:`, `check:` sections
- `<svc>.env` → optional, profile-specific env overrides loaded by `load-service-env`

Bifrost `config.json` uses `"env.VAR_NAME"` references resolved at startup — no envsubst templating. Never include a `config_store` block (bifrost v2.0.0 rejects it).

Switching profile: `ai-stack profile <name>` — stops stack, copies files, runs install if `AI_STACK_AUTO_INSTALL=true`, restarts.

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
3. Write `launch` (source ai-stack.env + load-service-env, exec via supervised-launch)
4. Optionally write `default.env` for service-local env defaults
5. Add entry to relevant profile `Procfile`s
6. Add to relevant profile `services.yaml` `install:` section (or `config/base-services.yaml` if universal)
7. Test: `ai-stack service install <name>` → `ai-stack service check <name>` → `ai-stack enable <name>`

## Adding a plugin

1. `mkdir lib/plugins/<name>`
2. Write `install` (handle install/upgrade/remove/check)
3. No `launch` — plugins are not daemons
4. Add to relevant profile `services.yaml` `plugins:` section
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

ai-install                             # machine bootstrap (prerequisites, runtimes, tooling)
ai-secrets init|edit|get|show|rotate   # secrets management
ai-models pull|list                    # model management
```

## What not to do

- Don't hardcode `$HOME` or absolute paths — always use `$AI_HOME` (set by `ai-stack.env`)
- Don't run `ai-stack` commands outside an activated profile — Procfile may be stale
- Don't edit `config/Procfile` directly — overwritten on profile switch; edit the profile source
- Don't commit `secrets/age-key.txt`, `secrets/api-keys.sops.yaml`, `config/.active-profile`, or `logs/`
- Don't assume services are running — check `ai-stack status` first
- Don't add a `config_store` block to any bifrost `config.json` — bifrost v2.0.0 rejects it
- Don't put AWS credentials or other secrets in committed env files — use `config/profiles/<profile>/<svc>.env` (gitignored) or SOPS secrets
