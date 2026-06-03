# Contributing to claude-local-stack

macOS + Apple Silicon only. No Windows/Linux support planned.

## Prerequisites

- Apple Silicon Mac (M1/M2/M3/M4)
- asdf, Homebrew, overmind installed
- SOPS + age for secrets

## Setup

```bash
git clone <repo> ~/ai-stack
cd ~/ai-stack
ai-install
```

## What to contribute

- Bug fixes for existing CLI tools (`bin/`)
- New profile definitions (`config/profiles/`)
- New service integrations (`lib/services/`)
- Documentation improvements (`docs/`)
- New model entries in `config/models.yaml`

## What not to contribute

- New external dependencies, Cross-platform abstractions without discussion first
- Secrets or API keys of any kind

## Workflow

1. Fork and create a branch: `git checkout -b feat/your-thing`
2. Make changes, test locally with `ai-stack start`
3. Keep commits conventional: `type(scope): short description`
4. Open a PR with a description of what changed and why

## Secrets

Never commit secrets. Use `ai-secrets edit` to manage keys locally.
The `secrets/` directory is gitignored except for the SOPS config template.

## Code style

Shell scripts: POSIX-compatible bash, 2-space indent, `set -euo pipefail` at top.
YAML: 2-space indent, no tabs.
