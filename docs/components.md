# Components — Services & Plugins

## Overview

Components live under `lib/` in two categories:

| Category | Path | Has a `launch` script | Managed by overmind |
|----------|------|-:--------------------:|-:-------------------:|
| **Services** | `lib/services/` | ✓ | ✓ |
| **Plugins** | `lib/plugins/` | ✗ | ✗ |

- A **service** is a long-running daemon (LLM server, proxy, router)
- A **plugin** is an install-only extension (CLI tool, editor integration, MCP config)

## Component structure

```
lib/services/headroom/
├── install          # idempotent install script (required)
├── remove           # uninstall script (optional)
├── launch           # start the daemon (services only)
├── priority         # install order (optional, default: 50)
└── readme.md        # description (optional)
```

### install

Sourced by `ai-stack-install`. Must be idempotent — skip work if already done.

```bash
#!/bin/zsh
set -euo pipefail
[[ -z "${AI_HOME:-}" ]] && source "$(dirname "$0")/../../../config/ai-stack.env"

if [[ already_installed ]]; then
  echo "  ✓ component-name"
  return 0
fi

# ... install logic ...
echo "  ✓ component-name"
```

### launch

Referenced by `config/Procfile`. Runs the service in the foreground (overmind handles backgrounding):

```bash
#!/bin/zsh
set -euo pipefail
source "$(dirname "$0")/../../../config/ai-stack.env"
exec some-server --port "${SOME_PORT}"
```

### remove

Reverses what `install` did:

```bash
#!/bin/zsh
set -euo pipefail
# ... cleanup logic ...
```

### priority

A single integer. Lower = installed earlier. Default is `50` when absent.

```bash
echo "10" > lib/services/headroom/priority
```

## Current components

### Services

| Name | Purpose |
|------|---------|
| rapid-mlx | Local LLM inference (MLX-accelerated) |
| headroom | Token compression proxy |
| claude-code-router | Multi-provider request router |
| voicemode | Voice interface (STT/TTS) |
| vllm-mlx | Alternative LLM server |

### Plugins

| Name | Purpose |
|------|---------|
| context-mode | Context management for Claude |
| superpowers | Extended Claude capabilities |
| caveman | Logging/debugging helper |
| rtk | Prompt toolkit |
| drawio | Diagram integration |
| atlassian | Jira/Confluence integration |

## Adding a new component

1. Create a directory under `lib/services/` or `lib/plugins/`
2. Add an `install` script (idempotent, sourced by the installer)
3. For services: add a `launch` script and a Procfile entry in `config/Procfile`
4. Optionally add `priority`, `remove`, `readme.md`

The installer discovers components automatically — see [installation](installation.md) for details.
