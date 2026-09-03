# Integration

Entry point for all tools: `http://localhost:8787` with `ANTHROPIC_API_KEY=local`.

See [README quick start](../README.md#quick-start) for prerequisites (profile active, stack running).

## Claude Code (CLI)

```bash
aclaude
```

## VS Code

```bash
acode
```

### Continue extension

`.continue/config.yaml`:

```yaml
models:
  - name: local
    provider: openai
    apiBase: http://localhost:8787/v1
    apiKey: local
    model: arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8
```

### Claude extension

`settings.json`:

```json
{
  "claude.apiEndpoint": "http://localhost:8787",
  "claude.apiKey": "local"
}
```

## Shell

Add to `~/.zshenv` (runs for all processes including GUI-launched apps):

```bash
export AI_HOME="$HOME/claude-local-stack"
export ANTHROPIC_BASE_URL="http://localhost:8787"
```

`AI_HOME` must be set before anything else — the stack bin and `ai-stack.env` both depend on it.
`ANTHROPIC_BASE_URL` ensures Claude Code always routes through the headroom proxy regardless of how it was launched. When headroom is not running, Claude Code will fail to connect — start the stack first with `ais`.

Add to `~/.zshrc` (terminal sessions):

```bash
export PATH="${AI_HOME}/bin:$PATH"

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
