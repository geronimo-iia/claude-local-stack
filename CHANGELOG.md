# claude-local-stack Changelog

All notable changes to this project will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [Unreleased]

### Added
- `lib/services/bifrost/`: Bifrost gateway service (install via npx, launch, readme)
- `lib/services/headroom/launch-bifrost`: headroom launch script pointing at Bifrost
- `BIFROST_PORT=4000` added to `config/ai-stack.env`
- `config/profiles/mistral-light/`: new minimal profile (mistral-small:24b only, ~16 GB RAM)
- `config/profiles/readme.md`: profile index table
- Ollama models added to `config/models.yaml`: `qwen3.8:27b-mtp-q4_K_M`, `qwen3:30b-a3b-instruct-2507-q4_K_M`
- `docs/roadmap/bifrost.md`: Bifrost vs LiteLLM comparison, MCP gateway analysis, full-stack architecture

### Changed
- `config/profiles/mistral/`: migrated from CCR to LiteLLM; `ccr.json` removed
- All `litellm.yaml` files: fixed model routing — now match actual Claude model name patterns (`claude-haiku*`, `claude-sonnet*`, `claude-opus*`, `*`) instead of CCR-style task-type aliases
- `config/models.yaml` llm section: replaced `arthurcollet/Qwen3.6-*` with `mlx-community/Qwen3.8-27B-MTP-4bit` and `mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B`
- `config/models.yaml` embedding section: replaced `all-MiniLM-L6-v2-4bit` + `bge-m3-mlx-4bit` with `Qwen3-Embedding-0.6B-4bit-DWQ` + `Qwen3-Embedding-4B-4bit-DWQ`
- `config/models.yaml` ollama: explicit `mistral-large:123b-instruct-2411-q4_K_M` tag (Q4_K_M guaranteed)
- `default/` and `local/` profiles: model refs updated to OptiQ/MTP/Qwen3.8 equivalents in `rapid-mlx.yaml` and `ccr.json`
- `lib/services/litellm/`: migrated from pip to uvx (no permanent install)

### Fixed
- `bin/ai-models`: inline YAML comments (`# ...`) no longer passed to `ollama pull` / `hf download`
- `bin/ai-stack` `_activate_profile`: broken service install loop replaced with `_install_yaml_deps` calls

### Added
- `lib/services/litellm/`: LiteLLM multi-provider proxy service (install, launch, priority 15, readme)
- `lib/services/headroom/launch-litellm`: headroom launch script pointing at LiteLLM (:4000)
- `config/profiles/multi/`: new profile (ollama + litellm + headroom, no CCR)
- `LITELLM_PORT=4000` added to `config/ai-stack.env`
- Profile activation copies `litellm.yaml` when present (same pattern as `rapid-mlx.yaml`)
- Profile dep tracking: `services.yaml` extended with `plugins:`, `mcp:`, `check:` sections
- `config/base-services.yaml`: universal deps for all profiles (claude-code, superpowers, overmind)
- `ai-stack check [profile]`: full dep report (base + profile — services, plugins, MCP, binaries)
- `ai-stack install [profile]`: installs all missing deps for a profile in one shot
- Profile switch auto-check: silent dep check on every `ai-stack profile <name>` with warning if missing
- `check)` case added to all service and plugin install scripts
- `lib/services/claude-code/`: moved from `lib/setup/claude-code/` — now a first-class service
- `ai-stack` CLI: start/stop/restart/status/logs/enable/disable/shell commands
- `ai-install` CLI: component-level install with cherry-pick support
- `ai-secrets` CLI: SOPS + age encrypted secrets management
- `ai-models` CLI: HuggingFace model manifest with pull/list commands
- Profile system: `default` (local MLX), `cloud` (AWS Bedrock)
- Headroom proxy integration (token compression, port 8787)
- CCR (claude-code-router) integration (multi-provider routing, port 3456)
- rapid-mlx local inference server integration (port 8000)
- Claude Code plugins: RTK, caveman, context-mode, superpowers, atlassian
- SOPS-encrypted secrets with age key management
- asdf-managed runtimes: Python 3.12, Node 22 LTS, Rust
- overmind Procfile-based process management
- Mermaid architecture diagrams in README
- Docs: cli, profiles, components, integration, models, secrets, overmind
