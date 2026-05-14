# Integration

Entry point for all tools: `http://localhost:8787` with `ANTHROPIC_API_KEY=local`.

## Prerequisites

1. Profile active: `ai-stack profile default`
2. Stack running: `ai-stack start`
3. For Bedrock profiles: `aws sso login --profile devops`

## Claude Code (CLI)

Env vars exported by `ai-stack shell`:

```bash
ANTHROPIC_BASE_URL=http://localhost:8787
ANTHROPIC_API_KEY=local
```

```bash
ai-stack shell
claude
```

## VS Code — Continue

`.continue/config.yaml`:

```yaml
models:
  - name: local
    provider: openai
    apiBase: http://localhost:8787/v1
    apiKey: local
    model: arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8
```

## VS Code — Claude extension

`settings.json`:

```json
{
  "claude.apiEndpoint": "http://localhost:8787",
  "claude.apiKey": "local"
}
```

## Shell aliases

```bash
export PATH="${HOME}/ai-stack/bin:$PATH"

# Stack
alias ais="ai-stack start"
alias aiq="ai-stack stop"
alias air="ai-stack restart"
alias aist="ai-stack status"
alias ail="ai-stack logs"
alias aip="ai-stack profile"

# Tools
alias aclaude="ai-stack shell claude"
alias acode="ai-stack shell code"

# Utilities
alias sec="ai-secrets"
alias aim="ai-models"
```
