# claude-local-stack Changelog

All notable changes to this project will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [Unreleased]

### Added
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
