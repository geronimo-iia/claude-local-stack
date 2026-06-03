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

## Cloud profile

The cloud profile bypasses CCR entirely. Headroom talks directly to AWS Bedrock:

```
Claude Code → Headroom (:8787, --backend bedrock) → AWS Bedrock
```

Uses `launch-cloud` script with `--backend bedrock` and AWS SSO credentials.

No `ccr.json` or `rapid-mlx.yaml` in this profile.
