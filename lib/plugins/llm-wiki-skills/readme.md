# llm-wiki-skills

Source: /Users/geronimo/dev/projects/llm-wiki/llm-wiki-skills

Claude Code plugin that teaches agents how to use the llm-wiki engine — manage spaces,
ingest sources, crystallize sessions, search knowledge, audit structure, and more.

Requires `llm-wiki` binary on PATH. The plugin starts `llm-wiki serve` automatically via MCP.

## Skills

| Skill | Invocation | Description |
|-------|-----------|-------------|
| `bootstrap` | Auto (session start) | Orient to a wiki — read config, types, hub pages |
| `ingest` | `/llm-wiki:ingest` | Process source files into synthesized wiki pages |
| `crystallize` | Auto + manual | Distil the current session into durable wiki pages |
| `research` | Auto + manual | Search the wiki and synthesize an answer |
| `content` | `/llm-wiki:content` | Read, create, update pages and sections |
| `lint` | `/llm-wiki:lint` | Audit quality — orphans, broken links, schema integrity |
| `graph` | `/llm-wiki:graph` | Generate and interpret the concept graph |
| `spaces` | `/llm-wiki:spaces` | Manage wiki spaces — create, list, inspect, remove |
| `schema` | `/llm-wiki:schema` | Understand and manage the type system |
| `stats` | `/llm-wiki:stats` | Wiki health dashboard |
| `review` | `/llm-wiki:review` | Process drafts, low-confidence pages, lint findings |
