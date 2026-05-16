# headroom

Token compression proxy between Claude Code and LLM backends. Supports local (via CCR) and cloud (AWS Bedrock) routing.

## Launch scripts

| Script         | Backend   | Chain                                    |
| -------------- | --------- | ---------------------------------------- |
| `launch`       | anthropic | Claude Code → Headroom → CCR → rapid-mlx |
| `launch-cloud` | bedrock   | Claude Code → Headroom → AWS Bedrock     |

## Installation

```bash
ai-install headroom
```

Installs `headroom-ai[all]` + `boto3` into a local venv. Registers MCP server in `~/.claude.json` with full venv path.

## Memory

Persistent user memory stored in a SQLite database.

| Env var                | Value                         | Purpose                   |
| ---------------------- | ----------------------------- | ------------------------- |
| `HEADROOM_MEMORY_PATH` | `${AI_HOME}/config/.headroom` | Directory for `memory.db` |

Memory features:
- `--memory` — enable persistent memory
- `--memory-db-path` — path to SQLite file
- `--no-memory-tools` — disable tool injection (passive context only)
- `--no-memory-context` — disable automatic context injection
- `--memory-top-k 10` — number of memories injected per request

MCP tools exposed to Claude Code:
- `headroom_stats` — usage statistics
- `headroom_compress` — manual compression

## Modes

| Mode    | Description               |
| ------- | ------------------------- |
| `token` | Active token compression  |
| `cache` | Cache-based deduplication |

## Optional flags

| Flag               | Purpose                                                       |
| ------------------ | ------------------------------------------------------------- |
| `--code-aware`     | AST-based code compression (requires tree-sitter)             |
| `--learn`          | Extract error→recovery patterns, writes to MEMORY.md          |
| `--min-evidence N` | Minimum observations before persisting a pattern (default: 5) |

## Cloud (Bedrock)

`launch-cloud` uses `--backend bedrock` with AWS SSO credentials.

| Env var       | Value     | Purpose         |
| ------------- | --------- | --------------- |
| `AWS_REGION`  | eu-west-1 | Bedrock region  |
| `AWS_PROFILE` | default   | AWS SSO profile |

Requires valid SSO session: `aws sso login --profile sbx`

Note: `AWS_DEFAULT_REGION` is also exported in `launch-cloud` to force litellm/boto3 region resolution.

## Claude Code integration

Env vars set in `config/ai-stack.env`:

```bash
ANTHROPIC_BASE_URL="http://localhost:${HEADROOM_PORT}"
```

`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` triggers auto-compaction at 70% context usage to keep token count manageable.

## Env vars

Set in `config/ai-stack.env`:

```bash
HEADROOM_PORT=8787
HEADROOM_MODE=token
HEADROOM_MEMORY_PATH="${AI_HOME}/config/.headroom"
```
