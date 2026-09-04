# Local Mistral + Claude Code Stack — Notes

## Hardware Requirements by Model

| Model | Min RAM/VRAM | Recommended | Disk |
|---|---|---|---|
| Mistral 7B / Ministral | 8 GB | 16 GB | ~5 GB |
| Mistral Small / Devstral Small (24B) | — | 16–24 GB (4-bit or 8-bit) | 14–25 GB |
| Mistral Large 2 (123B) — Q4_K_M or IQ4_XS | — | 65–73 GB | ~70 GB |
| Mistral Medium 3.5 (128B multimodal) — Q4_K_M | — | ~75 GB | ~75 GB |
| Mistral Small 4 — Q8_0 | — | ~30 GB | ~30 GB |

**Mistral Large 2** leaves 40 GB+ free for system and large context windows.  
**Mistral Small 4** runs at ~40 tokens/second with chat, vision, and coding.


## Setup

### Install & Run Ollama

```bash
brew install ollama
ollama run mistral-large
```

### Configure Claude Code Router (CCR)

CCR bridges Claude Code's Anthropic formatting to a local Ollama backend.

1. Launch CCR desktop app or CLI
2. Go to **Providers → Add Provider**, select **Ollama**
3. Set API URL: `http://127.0.0.1:11434`
4. Select `mistral-large` as the target model
5. Click **Start** (listens on `http://127.0.0.1:3456`)


## Step 1 — Extend the Context Window

```bash
# 64k tokens + Flash Attention (halves KV-cache memory on Apple Silicon)
OLLAMA_FLASH_ATTENTION=1 OLLAMA_CONTEXT_LENGTH=64000 ollama serve
```

Verify with `ollama ps` — check the `CONTEXT` column.

### Context window memory budget (Mistral Large 2 Q4_K_M, Apple Silicon)

| Context | KV-cache (FA only) | KV-cache (FA + q8_0) | Model weights | OS | Total (FA + q8_0) |
|---|---|---|---|---|---|
| 64k | ~8 GB | ~4 GB | ~70 GB | ~10 GB | ~84 GB |
| 128k | ~16 GB | ~8 GB | ~70 GB | ~10 GB | ~88 GB |
| 200k | ~25 GB | ~12–15 GB | ~70 GB | ~10 GB | ~92–95 GB |
| 1M | ~125 GB | ~60 GB | ~70 GB | ~10 GB | ✗ not feasible |

**For 200k context on 128 GB unified memory**, use both flags together:

```bash
OLLAMA_FLASH_ATTENTION=1 \
OLLAMA_KV_CACHE_TYPE=q8_0 \
OLLAMA_CONTEXT_LENGTH=200000 \
ollama serve
```

`OLLAMA_KV_CACHE_TYPE=q8_0` quantizes the KV-cache itself, cutting its footprint roughly in half again. Combined with flash attention, 200k context fits comfortably on 128 GB with ~30 GB to spare.

**1M context is not feasible on any current consumer hardware** — even at 192 GB. Use RAG or a hybrid local + API strategy instead (e.g. Gemini 1.5 Pro or Claude for rare long-context tasks).


## Step 2 — Multi-Agent Concurrency

### Ollama parallel config (`~/.zshrc`)

```bash
export OLLAMA_NUM_PARALLEL=3       # 3 concurrent agent channels
export OLLAMA_MAX_LOADED_MODELS=2  # 2 models in memory simultaneously
```

### Git Worktrees (prevent state thrashing)

```bash
git worktree add ../agent-feature-branch -b feature/new-ui-login
```

Open each worktree in a separate VS Code window and run `claude` or `ccr code` independently.

### Native Agent Teams (experimental)

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

Example prompt:
> "Analyze our API structure. Spawn 2 teammates: one for mock data servers, one for documentation."


## Step 3 — CLAUDE.md (Persistent Memory)

Create `CLAUDE.md` at the project root — Claude Code reads it at the start of every session.

```markdown
# Project Core Architecture

## Tech Stack
- Frontend: Next.js (App Router)
- Memory Store: Local Turbovec MCP (768-dim Nomic Embeddings)

## Constraints
- All backend routes must enforce strict type-checking.
- Never hardcode variables; use .env exclusively.
```


## Step 4 — Principal Architect System Prompt (`~/.claude.json`)

```json
{
  "system_prompt": "You are the Local Principal Architect Team Lead. You orchestrate parallel autonomous agents via Claude Code. Your engine is Mistral Large (123B) with access to an Episodic Memory MCP server.\n\n1. INITIAL RECALL — call search_memory before writing any code.\n2. DECOMPOSITION — map file dependencies, divide into isolated modules, queue conflicting edits sequentially.\n3. DELEGATION — assign teammates with explicit directory scopes and constraints.\n4. MONITORING — verify sub-agent changes against episodic memory.\n5. CONSOLIDATION — call create_memory or append_memory after completion. Log declarative summaries, not raw code."
}
```


## Step 5 — Episodic Memory Skills for Mistral

### 1. Dual-Phase Recall
> "Before debugging or implementing, always call `search_memory` first."

### 2. Continuous Consolidation
> "After every successful fix or feature, summarize and save via `create_memory` or `append_memory`."

### 3. Contextual Pruning
> "Write declarative knowledge vectors, not raw logs. E.g.: 'Project X uses absolute imports', 'User prefers Sentry for error tracking'."

### Test the setup

```
Seed:   "Remember I prefer fast-api routers over putting all endpoints in main.py."
Verify: "What are my structural preferences for this backend?"
```

### Update `~/.claude.json` tool mappings

- Context checks → `search_memories`
- Task consolidation → `memorize_fact` (after multi-agent merges)


## Step 6 — Agentic Paging Service (Virtual Context Manager)

A Python MCP service that pages inactive context blocks to Turbovec on SSD, keeping only a pointer in the active context window.

```python
import os
import json
import numpy as np
from mcp.server.fastmcp import FastMCP
import ollama
from turbovec import IdMapIndex

mcp = FastMCP("agentic-paging-service")

PAGE_SIZE_TOKENS = 2000
INDEX_PATH = os.path.expanduser("~/ai-stack/paging/v_memory.tq")
PAGE_TABLE_PATH = os.path.expanduser("~/ai-stack/paging/page_table.json")

index = IdMapIndex(dim=768, bit_width=4)
page_table = {}


@mcp.tool()
def swap_out_page(session_id: str, context_block: str, structural_tag: str) -> str:
    """Swap an inactive context block out to Turbovec SSD index."""
    global page_table
    page_id = len(page_table) + 1

    resp = ollama.embeddings(model="nomic-embed-text", prompt=f"{structural_tag}: {context_block}")
    vec = np.array(resp["embedding"], dtype=np.float32).reshape(1, -1)

    index.add_with_ids(vec, np.array([page_id], dtype=np.uint64))
    page_table[str(page_id)] = {"session": session_id, "tag": structural_tag, "data": context_block}

    index.write(INDEX_PATH)
    with open(PAGE_TABLE_PATH, "w") as f:
        json.dump(page_table, f)

    return f"Swapped out. Reference Pointer ID: {page_id}."


@mcp.tool()
def demand_page_in(query_urgency: str, limit: int = 1) -> str:
    """Page a required context block back into the active window."""
    if not page_table:
        return "Swap space is empty."

    resp = ollama.embeddings(model="nomic-embed-text", prompt=query_urgency)
    query_vec = np.array(resp["embedding"], dtype=np.float32)
    scores, ids = index.search(query_vec, k=limit)

    results = []
    for page_id in ids:
        if str(page_id) in page_table:
            page_data = page_table[str(page_id)]
            results.append(f"--- PAGE (Tag: {page_data['tag']}) ---\n{page_data['data']}")

    return "\n".join(results) if results else "Page Miss: context not found."
```

### Agent prompt for paging

> "You have a 64k token limit. When a file or discussion is no longer immediately relevant, call `swap_out_page`. If a sub-agent hits a missing dependency, call `demand_page_in`."
