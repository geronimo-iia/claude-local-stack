# Claude Code Router (CCR) — Multi-model Task Router

Source: https://github.com/musistudio/claude-code-router

Routes requests by task type (default, background, think, longContext) to different models/providers.
Sits between Headroom and the backends.

## Call chain position

```
Claude Code → Headroom (:8787) → CCR (:3456) → Rapid-MLX (:8000) / Bedrock / Anthropic
```

## Configuration

Config file: `~/.claude-code-router/config.json`

Generated from `config-default.json` during install with the port injected.

## Commands

```bash
ccr start         # start server
ccr stop          # stop server
ccr restart       # restart server
ccr status        # show server status
ccr activate      # output env vars for shell integration
ccr model         # interactive model selection
ccr ui            # web UI at http://localhost:3456/ui/
```

## Shell integration

Add to `~/.zshrc`:

```bash
eval "$(ccr activate)"
```

## Routing task types

| Task type     | When CCR uses it                                       |
| ------------- | ------------------------------------------------------ |
| `default`     | Normal coding, file edits, general chat                |
| `background`  | Lightweight tasks (linting, formatting, quick lookups) |
| `think`       | Complex reasoning, planning, architecture decisions    |
| `longContext` | Large file reads, big diffs, documentation ingestion   |
| `webSearch`   | Web search queries                                     |
| `image`       | Image-related tasks                                    |

## Switch model live (inside Claude Code)

```
/model provider,model-name
```

## Env vars

- `CCR_PORT` — port the router listens on (default: 3456)
