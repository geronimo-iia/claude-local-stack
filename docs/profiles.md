# Profiles

A profile is a complete stack configuration: routing rules + service definitions + model config + install manifest.

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
7. Restarts services (if was running)

## services.yaml

Declares which services must be installed for the profile to work:

```yaml
# config/profiles/default/services.yaml
install:
  - headroom
  - claude-code-router
  - rapid-mlx
```

```yaml
# config/profiles/cloud/services.yaml
install:
  - headroom
```

Install scripts are idempotent — safe to run on every profile switch.

## Auto-install

Controlled by env var in `config/ai-stack.env`:

```bash
AI_STACK_AUTO_INSTALL="true"    # run install on profile switch
```

Set to `"false"` for fast switching (CI, already-installed environments).

## Runtime overrides

`enable`/`disable` modify the active Procfile without touching the profile source:

```bash
ai-stack disable headroom    # temporary override
ai-stack profile hybrid      # resets Procfile to profile's definition
```

## Mistral profile

The mistral profile uses Ollama as the inference backend instead of rapid-mlx. No `rapid-mlx.yaml` — Ollama is configured via env vars in `config/ai-stack.env`.

```
Claude Code → Headroom (:8787) → CCR (:3456) → Ollama (:11434) → Mistral Large 2 (123B)
```

Key env vars (all have defaults in the `ollama` launch script):

```bash
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
