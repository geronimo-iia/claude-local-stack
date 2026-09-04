# Profiles

A profile is a complete stack configuration: routing rules + service definitions + model config + install manifest.

## Overview

| Profile        | Backend                        | Min RAM | Notes                                           |
| -------------- | ------------------------------ | ------- | ----------------------------------------------- |
| local          | rapid-mlx (Qwen3.6-35B)        | 32 GB   | Fully offline; headroom → bifrost → rapid-mlx   |
| max            | Anthropic API                  | any     | Claude Max plan; headroom → bifrost → Anthropic |
| max-direct     | Anthropic API                  | any     | Headroom direct to Anthropic, no bifrost        |
| bedrock        | AWS Bedrock                    | any     | Headroom → bifrost → Bedrock                    |
| bedrock-direct | AWS Bedrock                    | any     | Headroom direct to Bedrock, no bifrost          |
| mistral        | Ollama (Mistral Large 123B)    | 128 GB  | Headroom → bifrost → Ollama                     |
| mistral-light  | Ollama (Mistral Small 24B)     | 64 GB   | Headroom → bifrost → Ollama                     |
| rapid-mlx-test | rapid-mlx (model benchmarking) | 32 GB   | Headroom → bifrost → rapid-mlx                  |

## Structure

```
config/profiles/
├── local/
│   ├── bifrost/
│   │   └── config.json        # → config/.bifrost/config.json (no secrets)
│   ├── rapid-mlx.yaml         # → config/rapid-mlx.yaml
│   ├── Procfile               # → config/Procfile
│   └── services.yaml
├── max/
│   ├── bifrost/
│   │   └── config.json        # → config/.bifrost/config.json
│   ├── Procfile
│   └── services.yaml
├── max-direct/
│   ├── Procfile
│   └── services.yaml
├── bedrock/
│   ├── bifrost/
│   │   └── config.json        # → config/.bifrost/config.json (env.VAR refs resolved at startup)
│   ├── bifrost.env            # AWS credentials — loaded by bifrost launch via load-service-env
│   ├── Procfile
│   └── services.yaml
├── bedrock-direct/
│   ├── Procfile
│   └── services.yaml
├── mistral/
│   ├── bifrost/
│   │   └── config.json        # → config/.bifrost/config.json (no secrets)
│   ├── Procfile
│   └── services.yaml
├── mistral-light/
│   ├── bifrost/
│   │   └── config.json
│   ├── Procfile
│   └── services.yaml
└── rapid-mlx-test/
    ├── bifrost/
    │   └── config.json
    ├── rapid-mlx.yaml
    ├── Procfile
    └── services.yaml
```

## Activation

```bash
ai-stack profile <name>
ai-stack profile <name> --force   # re-activate even if already active
```

1. Stops current services (if running)
2. Copies `rapid-mlx.yaml` → `config/rapid-mlx.yaml` (if present)
3. Copies `bifrost/` dir → `config/.bifrost/` (if present — replaces entire dir; includes `.tpl` files)
4. Copies `Procfile` → `config/Procfile`
5. If `AI_STACK_AUTO_INSTALL=true`: runs `ai-install <svc>` for each service in `services.yaml`
6. Writes profile name to `config/.active-profile`
7. Runs silent dep check — warns if anything is missing
8. Restarts services (if was running)

All bifrost `config.json` files use `"env.VAR_NAME"` references resolved by bifrost at startup. Profile-specific credentials (e.g. AWS for the `bedrock` profile) are injected via `config/profiles/<profile>/<svc>.env`, loaded by `lib/utils/load-service-env` before the service starts.

## services.yaml

Declares all deps for a profile — services, plugins, MCP registrations, and arbitrary binaries:

```yaml
# config/profiles/default/services.yaml
install:          # services to install — ai-stack service install <name>
  - headroom
  - bifrost
  - rapid-mlx

plugins:          # Claude Code plugins — ai-stack plugin install <name>
  - caveman
  - context-mode
  - agent-skills

mcp:              # MCP servers that must be registered in ~/.claude.json
  - headroom

check:            # arbitrary binaries that must exist (no install action)
  - overmind
```

All sections are optional. Existing `install:`-only files remain valid.

## base-services.yaml

`config/base-services.yaml` lists deps required by **all** profiles — checked and installed before any profile-specific deps:

```yaml
install:
  - claude-code

plugins:
  - superpowers

check:
  - overmind
```

## Dep checking

```bash
ai-stack check              # full report for active profile (base + profile)
ai-stack check cloud        # report for a named profile without switching
ai-stack install            # install all missing deps for active profile
ai-stack install cloud      # install for a named profile without switching
```

On every profile switch, a silent check runs automatically — prints `⚠ Deps missing. Run: ai-stack install` if anything is missing.

## Auto-install

Controlled by env var in `config/ai-stack.env`:

```bash
AI_STACK_AUTO_INSTALL="true"    # run service install on profile switch
```

Set to `"false"` for fast switching (CI, already-installed environments). `ai-stack install` is the explicit alternative.

## Runtime overrides

`enable`/`disable` modify the active Procfile without touching the profile source:

```bash
ai-stack disable headroom    # temporary override
ai-stack profile hybrid      # resets Procfile to profile's definition
```

## Mistral profile

Uses Ollama as the inference backend. No `rapid-mlx.yaml` — Ollama is configured via `lib/services/ollama/default.env` (overridable per-profile via `config/profiles/<profile>/ollama.env`).

Key env vars (defaults in `lib/services/ollama/default.env`):

```bash
OLLAMA_KEEP_ALIVE=5m           # unload inactive models after 5 minutes
OLLAMA_FLASH_ATTENTION=1       # halves KV-cache memory
OLLAMA_KV_CACHE_TYPE=q8_0     # quantizes KV-cache
OLLAMA_CONTEXT_LENGTH=200000   # 200k context window
```

## Bedrock-direct profile

Headroom talks directly to AWS Bedrock:

```
Claude Code → Headroom (:8787, --backend bedrock) → AWS Bedrock
```

Uses `launch-bedrock` script. AWS credentials injected via `config/profiles/bedrock-direct/headroom.env` at launch.
