# Changelog

## 2026-09-06

### Docs
- Added 5 architecture decision records in `docs/decisions/` — bifrost over LiteLLM, per-service env layering, profile-driven install, supervised-launch over overmind auto-restart, headroom as stack entry point
- Added `docs/invariants.md` with rules grouped by category (config, boot order, service contract, profiles, security); linked from AGENTS.md
- Rewrote `AGENTS.md` for current stack — bifrost, env layering, invariants section, no CCR/LiteLLM references
- Added cross-links between decision files and the docs they reference
- Added troubleshooting guide (`docs/troubleshooting.md`)
- Applied anti-slop pass across all docs — fixed passive voice, removed filler connectors
- Updated README: max profile architecture diagram, full plugin table with roles and GitHub links
- Updated GitHub repo description and topics

## 2026-09-05

### Changed
- `ai-install` is now bootstrap-only (prerequisites, runtimes, tooling). Service and plugin installation is delegated to `ai-stack install`, which reads `base-services.yaml` + active profile's `services.yaml`
- Per-service env layering: service-specific vars moved from `config/ai-stack.env` to `lib/services/<svc>/default.env`; profile overrides in `config/profiles/<profile>/<svc>.env`; loaded by new `lib/utils/load-service-env` helper
- AWS profile env files now use `${AWS_PROFILE:-default}` and `${AWS_REGION:-eu-west-1}` — no hardcoded profile names
- Added `config/.env` local override sourced last by `ai-stack.env` (gitignored)

### Removed
- LiteLLM service and all `litellm.yaml` files across profiles
- CCR (was replaced by bifrost in prior work)
- `docs/brainstorm/` scratch directory

## 2026-09-04

### Added
- Bifrost migration across all profiles — replaces LiteLLM as the routing layer; correctly forwards `tools` to OpenAI-compatible backends
- `bedrock` profile (renamed from `aws-bedrock`); AWS credentials scoped to bifrost env file via `load-service-env`
- `rapid-mlx-test` profile with Qwen3.6-35B-A3B-4bit + MTP for speed benchmarking (~73 t/s measured)
- `--force` flag for `ai-stack profile` to re-activate an already-active profile
- `ai-stack status` shows active profile name
- `local` profile: switched default model to Qwen3.6-35B-A3B-4bit with MTP

### Fixed
- Bedrock bifrost config: correct `bedrock` provider type (was `openai`)
- `ai-stack profile --force` accepted before or after profile name
- Plugin `check` subcommand added to rtk, karpathy-skills, rust-analyzer-lsp

### Removed
- LiteLLM from `rapid-mlx-test`, `max`, `aws-bedrock` profiles
- Unused model entries (DeepSeek-Coder-V2-Lite, Qwen3.8-27B MTP) from manifest
