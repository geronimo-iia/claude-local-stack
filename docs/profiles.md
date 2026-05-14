# Profiles

A profile is a complete stack configuration: routing rules + service definitions + model config.

## Structure

```
config/profiles/
├── default/
│   ├── ccr.json         # → ~/.claude-code-router/config.json
│   ├── rapid-mlx.yaml   # → config/rapid-mlx.yaml
│   └── Procfile         # → config/Procfile
├── local/
│   ├── ccr.json
│   ├── rapid-mlx.yaml
│   └── Procfile
├── hybrid/
│   ├── ccr.json
│   ├── rapid-mlx.yaml
│   └── Procfile
└── cloud/
    ├── ccr.json
    └── Procfile          # no rapid-mlx.yaml (no local models)
```

## Activation

```bash
ai-stack profile hybrid
```

1. Stops current services (if running)
2. Copies `ccr.json` → `~/.claude-code-router/config.json`
3. Copies `rapid-mlx.yaml` → `config/rapid-mlx.yaml` (if present)
4. Copies `Procfile` → `config/Procfile`
5. Writes profile name to `config/.active-profile`
6. Restarts services (if was running)

## Routing matrix

| Task        | default                       | local                         | hybrid                        | cloud               |
| ----------- | ----------------------------- | ----------------------------- | ----------------------------- | ------------------- |
| default     | rapid-mlx :8000 (Qwen3.6-35B) | rapid-mlx :8000 (Qwen3.6-35B) | rapid-mlx :8000 (Qwen3.6-35B) | Bedrock (Sonnet 4)  |
| background  | rapid-mlx :8000 (Qwen3.6-35B) | rapid-mlx :8001 (Qwen3.6-27B) | rapid-mlx :8001 (Qwen3.6-27B) | Bedrock (Haiku 4.5) |
| think       | rapid-mlx :8000 (Qwen3.6-35B) | rapid-mlx :8002 (Qwen3-235B)  | Bedrock (Sonnet 4)            | Bedrock (Opus 4)    |
| longContext | rapid-mlx :8000 (Qwen3.6-35B) | rapid-mlx :8000 (Qwen3.6-35B) | Bedrock (Sonnet 4)            | Bedrock (Sonnet 4)  |

## Services per profile

| Service              | default | local | hybrid | cloud |
| -------------------- | :-----: | :---: | :----: | :---: |
| rapid-mlx-default    |    ✓    |   ✓   |   ✓    |   ✗   |
| rapid-mlx-background |    ✗    |   ✓   |   ✓    |   ✗   |
| rapid-mlx-think      |    ✗    |   ✓   |   ✗    |   ✗   |
| headroom             |    ✓    |   ✓   |   ✓    |   ✗   |
| ccr                  |    ✓    |   ✓   |   ✓    |   ✓   |

## Runtime overrides

`enable`/`disable` modify the active Procfile without touching the profile source:

```bash
ai-stack disable headroom    # temporary override
ai-stack profile hybrid      # resets Procfile to profile's definition
```
