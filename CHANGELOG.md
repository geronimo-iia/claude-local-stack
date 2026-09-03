# claude-local-stack Changelog

All notable changes to this project will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [Unreleased]

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
