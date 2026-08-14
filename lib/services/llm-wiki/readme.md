# llm-wiki

Source: https://github.com/geronimo-iia/llm-wiki

Headless wiki engine for agents. Git-backed Markdown wiki — searchable, typed, graph-linked.
Single Rust binary. No runtime, no database.

Installed via Homebrew tap `geronimo-iia/tap/llm-wiki`.

## No launch script

`llm-wiki serve` is started automatically by the `llm-wiki-skills` Claude Code plugin via MCP.
This service only manages the binary installation.

## Key commands

```bash
llm-wiki spaces list          # list registered wikis
llm-wiki spaces create <path> --name <name>
llm-wiki search "<query>"
llm-wiki ingest wiki/
llm-wiki serve                # start MCP server (stdio)
llm-wiki serve --watch        # start MCP server with live indexing
```

## Wiki root

Wikis are registered in `~/.llm-wiki/config.toml`.
Main knowledge folder: ~/dev/knowledge/
