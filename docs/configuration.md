# Configuration

## Overview

Configuration is split by concern:

| File | Scope | What it configures |
|------|-------|--------------------|
| `config/ai-stack.env` | Project | Paths only (`AI_HOME`, `SOPS_AGE_KEY_FILE`) |
| `config/Procfile` | Services | Which services run and how |
| `config/ccr-config.json` | CCR | Model routing, providers, task types |
| `secrets/api-keys.sops.yaml` | Secrets | API keys (encrypted) |
| `~/.claude/mcp.json` | Claude Code | MCP server registrations (voicemode, context-mode) |
| `~/.claude/settings.json` | Claude Code | RTK hook |

## `config/ai-stack.env`

Project paths. Sourced by `bin/ai-stack`, inherited by all services.

```bash
# Project root — resolved from this file's location
AI_HOME="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"

# Age private key for SOPS secret decryption
SOPS_AGE_KEY_FILE="$AI_HOME/secrets/age-key.txt"
```

Nothing else belongs here. Service-specific config goes in the service's own config file.

## `config/Procfile`

Defines services for overmind. Each line: `name: command`.

```procfile
rapid-mlx: HF_HOME=$AI_HOME/models/llm $AI_HOME/services/rapid-mlx/.venv/bin/rapid-mlx serve --model ${AI_STACK_MODEL:-arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8} --port ${RAPID_MLX_PORT:-8000}
headroom: headroom serve --port ${HEADROOM_PORT:-8787} --upstream http://localhost:${RAPID_MLX_PORT:-8000}/v1
ccr: ccr start
```

Service-specific env vars (`HF_HOME`, `AI_STACK_MODEL`, ports) are set inline or overridden at runtime.

## `config/ccr-config.json`

Claude Code Router configuration. Symlinked to `~/.claude-code-router/config.json`:

```bash
ln -sf <repo>/config/ccr-config.json ~/.claude-code-router/config.json
```

Key sections:

| Section | Purpose |
|---------|---------|
| `Providers` | Backend definitions (URL, models, transformer) |
| `Router` | Task type → provider,model mapping |

See [CCR docs](../../articles/local-ai-stack/docs/04-ccr.md) for full reference.

## External config (not in this repo)

### `~/.claude/mcp.json`

MCP servers for Claude Code. Managed via `claude mcp add/remove`:

```json
{
  "mcpServers": {
    "voicemode": {
      "command": "uvx",
      "args": ["voice-mcp"],
      "env": {
        "WHISPER_MODEL": "base",
        "WHISPER_MODEL_DIR": "<repo>/models/whisper",
        "KOKORO_MODEL_DIR": "<repo>/models/kokoro"
      }
    }
  }
}
```

### `~/.claude/settings.json`

RTK hook (installed by `rtk init -g`):

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": "rtk hook claude" }] }
    ]
  }
}
```

## Runtime overrides

Override any Procfile default via env vars:

```bash
AI_STACK_MODEL=mlx-community/Qwen3-235B-A22B-4bit ai-stack restart rapid-mlx
RAPID_MLX_PORT=9000 ai-stack restart rapid-mlx
HEADROOM_PORT=9787 ai-stack restart headroom
```

## Switching local ↔ cloud

```bash
# Local (via CCR)
claude config set --global apiBaseUrl http://localhost:3456/v1

# Cloud (Anthropic)
claude config set --global apiBaseUrl https://api.anthropic.com

# Check
claude config get --global apiBaseUrl
```
