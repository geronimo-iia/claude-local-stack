# Profiles

A profile is a complete stack configuration: routing rules + service definitions + model config + install manifest.

## Overview

| Profile | Instances | Min RAM | Notes |
|---------|-----------|---------|-------|
| default | rapid-mlx ×1 | 32 GB | Single MoE model, fits most hardware |
| local | rapid-mlx ×2 | 64 GB | think instance opt-in (128 GB required) |
| hybrid | rapid-mlx ×2 | 64 GB | Bedrock for think/longContext |
| mistral | ollama ×1 | 128 GB | Two Ollama models, large context |
| cloud | none | any | Bedrock only, no local inference |
| multi | ollama ×1 + litellm | 128 GB | LiteLLM router: Ollama + Bedrock + Anthropic API |

## Structure

```
config/profiles/
├── default/
│   ├── ccr.json           # → ~/.claude-code-router/config.json
│   ├── rapid-mlx.yaml    # → config/rapid-mlx.yaml
│   ├── Procfile           # → config/Procfile
│   └── services.yaml      # services to install on activation
├── local/
│   ├── ccr.json
│   ├── rapid-mlx.yaml
│   ├── Procfile
│   └── services.yaml
├── hybrid/
│   ├── ccr.json
│   ├── rapid-mlx.yaml
│   ├── Procfile
│   └── services.yaml
├── mistral/
│   ├── ccr.json           # routes all tiers to Ollama (:11434)
│   ├── Procfile           # ollama + headroom + ccr
│   └── services.yaml      # ollama + headroom + claude-code-router
└── cloud/
    ├── ccr.json
    ├── Procfile           # headroom only (no CCR, no rapid-mlx)
    └── services.yaml
```

## Activation

```bash
ai-stack profile hybrid
```

1. Stops current services (if running)
2. Copies `ccr.json` → `~/.claude-code-router/config.json`
3. Copies `rapid-mlx.yaml` → `config/rapid-mlx.yaml` (if present)
4. Copies `Procfile` → `config/Procfile`
5. If `AI_STACK_AUTO_INSTALL=true`: runs `ai-install <svc>` for each service in `services.yaml`
6. Writes profile name to `config/.active-profile`
7. Runs silent dep check — warns if anything is missing
8. Restarts services (if was running)

## services.yaml

Declares all deps for a profile — services, plugins, MCP registrations, and arbitrary binaries:

```yaml
# config/profiles/default/services.yaml
install:          # services to install — ai-stack service install <name>
  - headroom
  - claude-code-router
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

Uses Ollama as the inference backend instead of rapid-mlx. No `rapid-mlx.yaml` — Ollama is configured via env vars in `config/ai-stack.env`.

```
Claude Code → Headroom (:8787) → CCR (:3456) → Ollama (:11434) → mistral-large:123b  [default / think / longContext]
                                                                  → mistral-small:24b  [background]
```

Key env vars (all have defaults in the `ollama` launch script):

```bash
OLLAMA_KEEP_ALIVE=5m           # unload inactive models after 5 minutes
OLLAMA_FLASH_ATTENTION=1       # halves KV-cache memory
OLLAMA_KV_CACHE_TYPE=q8_0     # quantizes KV-cache
OLLAMA_CONTEXT_LENGTH=200000   # 200k context window
```

See `lib/services/ollama/readme.md` for the full variable reference.

## Cloud profile

The cloud profile bypasses CCR entirely. Headroom talks directly to AWS Bedrock:

```
Claude Code → Headroom (:8787, --backend bedrock) → AWS Bedrock
```

Uses `launch-cloud` script with `--backend bedrock` and AWS SSO credentials.

No `ccr.json` or `rapid-mlx.yaml` in this profile.
