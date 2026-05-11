# context-mode — Context Sandboxing + Local Knowledge Base

Source: https://github.com/scottconverse/context-mode

Claude Code plugin that sandboxes tool output and compresses what returns to the context window.
Maintains a local knowledge base (FTS5/BM25) that persists across compactions.

## Tools provided

| Tool | What it does |
|------|-------------|
| `ctx_fetch_and_index` | Fetch URL + index into local KB (replaces WebFetch) |
| `ctx_search` | BM25 search across indexed content |
| `ctx_batch_execute` | Run multiple tools, sandbox output, compress results |
| `ctx_execute` | Run a single tool with sandboxed output |
| `ctx_execute_file` | Execute file operations with compression |
| `ctx_index` | Index content into the local KB |
| `ctx_stats` | Token savings for current session |
| `ctx_snapshot` | Save session state before compaction |
| `ctx_restore` | Restore state after compaction |

## Savings

30–98% token reduction depending on session type (research-heavy sessions benefit most).

## CLAUDE.md rules to enforce usage

```markdown
## Context Rules
- Never use WebFetch directly — always use ctx_fetch_and_index
- For multi-file reads, use ctx_batch_execute instead of sequential reads
- Run ctx_stats at session end to track savings
```
