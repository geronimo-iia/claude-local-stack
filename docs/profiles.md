# Profiles

A profile is a complete stack configuration: routing rules + service definitions + model config + install manifest.

## Overview

| Profile | Backend | Min RAM | Notes |
|---------|---------|---------|-------|
| local | rapid-mlx ×1 | 32 GB | Single Qwen3.6-35B MoE, fully offline |
| max | Anthropic API | any | Claude Max plan, local fallback on 429 |
| max-direct | Anthropic API | any | Direct to Anthropic, no LiteLLM |
| bedrock-direct | AWS Bedrock | any | Headroom → Bedrock, no LiteLLM |
| mistral | ollama ×1 | 128 GB | Mistral Large + Small via Ollama |
| rapid-mlx-test | rapid-mlx (bifrost) | 32 GB | Model benchmarking profile; uses bifrost instead of litellm |

## Structure

```
config/profiles/
├── local/
│   ├── litellm.yaml       # → config/litellm.yaml
│   ├── rapid-mlx.yaml     # → config/rapid-mlx.yaml
│   ├── Procfile           # → config/Procfile
│   └── services.yaml      # services to install on activation
├── max/
│   ├── litellm.yaml
│   ├── Procfile
│   └── services.yaml
├── max-direct/
│   ├── Procfile
│   └── services.yaml
├── bedrock-direct/
│   ├── Procfile
│   └── services.yaml
├── mistral/
│   ├── Procfile
│   └── services.yaml
└── rapid-mlx-test/
    ├── bifrost/           # → config/.bifrost/ (entire dir)
    │   └── config.json    # bifrost file-only config (no DB)
    ├── rapid-mlx.yaml
    ├── Procfile
    └── services.yaml
```

## Activation

```bash
ai-stack profile hybrid
```

1. Stops current services (if running)
2. Copies `litellm.yaml` → `config/litellm.yaml` (if present)
3. Copies `rapid-mlx.yaml` → `config/rapid-mlx.yaml` (if present)
4. Copies `bifrost/` dir → `config/.bifrost/` (if present — replaces entire dir)
5. Copies `Procfile` → `config/Procfile`
6. If `AI_STACK_AUTO_INSTALL=true`: runs `ai-install <svc>` for each service in `services.yaml`
7. Writes profile name to `config/.active-profile`
8. Runs silent dep check — warns if anything is missing
9. Restarts services (if was running)

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

Uses Ollama as the inference backend. No `rapid-mlx.yaml` or `litellm.yaml` — Ollama is configured via env vars in `config/ai-stack.env`.

Key env vars (all have defaults in the `ollama` launch script):

```bash
OLLAMA_KEEP_ALIVE=5m           # unload inactive models after 5 minutes
OLLAMA_FLASH_ATTENTION=1       # halves KV-cache memory
OLLAMA_KV_CACHE_TYPE=q8_0     # quantizes KV-cache
OLLAMA_CONTEXT_LENGTH=200000   # 200k context window
```

See `lib/services/ollama/readme.md` for the full variable reference.

## Bedrock-direct profile

Headroom talks directly to AWS Bedrock:

```
Claude Code → Headroom (:8787, --backend bedrock) → AWS Bedrock
```

Uses `launch-bedrock` script with AWS SSO credentials. No LiteLLM in the path.
