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

## Observability

Dashboard and stats commands (proxy must be running on port 8787):

| Command | Description |
|---------|-------------|
| `headroom dashboard` | Opens savings dashboard in browser |
| `headroom perf` | Analyzes proxy performance from logs |
| `headroom savings` | Durable compression savings over time |
| `headroom inspect` | Original vs compressed content for recent requests |
| `headroom output-savings` | Output token reduction stats |

## Logs

Two log locations:

**`$AI_HOME/logs/`** — stdout/stderr from supervised-launch (via `--log-file`):

| File | Profile |
|------|---------|
| `headroom.log` | default (no date suffix) |
| `headroom-YYYY-MM-DD.log` | cloud and max profiles |

**`~/.headroom/logs/`** — internal proxy logs (rotated):

| File | Contents |
|------|----------|
| `proxy.log` | current — PERF lines, cache stats, request trace |
| `proxy.log.1`, `.2`, `.3` | rotated (~10M each) |
| `debug_400/` | captured 400 error payloads |

PERF lines in `proxy.log` contain per-request `cache_read` / `cache_write` counters. Use these to verify prompt caching is active.

## Env vars

Set in `config/ai-stack.env`:

```bash
HEADROOM_PORT=8787
HEADROOM_MODE=token
HEADROOM_MEMORY_PATH="${AI_HOME}/config/.headroom"
```
