# Claude Code — AI Coding Agent

Source: https://github.com/anthropics/claude-code

CLI agent that operates directly in the terminal. Reads, writes, and reasons about code.
Entry point of the ai-stack — all requests flow from here through the chain.

## Call chain

```
Claude Code → Headroom (:8787) → CCR (:3456) → Rapid-MLX (:8000) / Bedrock / Anthropic
```

## Configuration

Settings: `~/.claude/settings.json`
MCP servers: `~/.claude/mcp.json`
Project rules: `.claude/` in any repo

## Key env vars

- `ANTHROPIC_BASE_URL` — where requests go (headroom in our stack)
- `ANTHROPIC_API_KEY` — API key (set to `local` for local stack)
