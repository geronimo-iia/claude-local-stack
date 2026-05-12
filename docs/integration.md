# Integration

How to connect tools to the ai-stack. The entry point is always Headroom (`http://localhost:8787`) which routes through CCR to backends.

## Claude Code (CLI)

`config/ai-stack.env` exports the required variables:

```bash
ANTHROPIC_BASE_URL=http://localhost:8787
ANTHROPIC_API_KEY=local
```

These are sourced automatically by the `aclaude` alias (see below).

## VS Code — Continue

In `.continue/config.yaml`:

```yaml
models:
  - name: local
    provider: openai
    apiBase: http://localhost:8787/v1
    apiKey: local
    model: arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8
```

## VS Code — Claude extension

In VS Code settings (`settings.json`):

```json
{
  "claude.apiEndpoint": "http://localhost:8787",
  "claude.apiKey": "local"
}
```

## Call chain

```
Tool → Headroom (:8787) → CCR (:3456) → rapid-mlx / Bedrock
```

## Prerequisites

1. Stack is running: `ai-stack start`
2. A profile is active: `ai-stack profile default`
3. For Bedrock profiles: AWS session is valid (`aws sso login --profile devops`)

## Shell aliases

Add to `~/.zshrc`:

```bash

export "${HOME}/ai-stack/bin:$PATH"

# Stack management
alias ais="ai-stack start"
alias aiq="ai-stack stop"
alias air="ai-stack restart"
alias aist="ai-stack status"
alias ail="ai-stack logs"
alias aip="ai-stack profile"

# Launch tools through the stack
alias aclaude="ai-schell claude"
alias acode="ai-schell code"

# Secrets
alias sec="ai-secrets"

# Models
alias aim="ai-models"
```
