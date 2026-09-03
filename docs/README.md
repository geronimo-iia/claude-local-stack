# ai-stack — Reference

Local AI inference infrastructure for Claude Code on Apple Silicon. Provides offline multi-model routing, token compression, voice, and AWS Bedrock fallback.

## Architecture

Profile-dependent. Typical flows:

```
# local / max
Claude Code → Headroom (:8787) → LiteLLM (:4000) → rapid-mlx (:8000)
                                                   → Anthropic API

# max-direct
Claude Code → Headroom (:8787) → Anthropic API

# bedrock-direct
Claude Code → Headroom (:8787, --backend bedrock) → AWS Bedrock
```

## Repository layout

```
bin/              # CLI entry points (ai-stack, ai-install, ai-secrets, ai-models)
config/
  ai-stack.env   # env vars, ports, Overmind config
  profiles/      # local | max | max-direct | bedrock-direct | mistral — each has Procfile + optional litellm.yaml/rapid-mlx.yaml
  Procfile       # active service definitions (copied from active profile)
  models.yaml    # model manifest (HuggingFace repo IDs)
lib/
  setup/         # bootstrap scripts (prerequisites, runtimes, tooling)
  services/      # daemons: rapid-mlx, litellm, headroom, voicemode; binaries: llm-wiki
  plugins/       # Claude Code extensions: rtk, context-mode, superpowers, caveman, drawio, atlassian, llm-wiki-skills
  utils/         # supervised-launch (restart wrapper), token-savings (dashboard)
secrets/         # SOPS + age encrypted secrets (age-key.txt and api-keys.sops.yaml are gitignored)
logs/            # runtime output (gitignored)
docs/            # reference docs per topic
```

## Key files

| File | Purpose |
|------|---------|
| `config/ai-stack.env` | All env vars — sourced first before anything else |
| `config/.active-profile` | Current profile name (runtime state, gitignored) |
| `config/profiles/*/Procfile` | Services to run per profile |
| `config/profiles/*/litellm.yaml` | LiteLLM routing config per profile (LiteLLM profiles only) |
| `config/profiles/*/rapid-mlx.yaml` | Model instance definitions per profile (rapid-mlx profiles only) |
| `config/profiles/*/services.yaml` | Services to install on profile activation |
| `lib/utils/supervised-launch` | Restart wrapper: 5 attempts / 60s window, exponential backoff |
| `lib/utils/token-savings` | CLI dashboard showing RTK + Headroom token savings |

## Stack management

```bash
ai-stack start              # start all services (daemonized via Overmind)
ai-stack stop               # stop all
ai-stack restart [svc]      # restart all or one service
ai-stack status             # running processes
ai-stack enable <svc...>    # uncomment in Procfile, restart if running
ai-stack disable <svc...>   # comment in Procfile, restart if running
ai-stack logs [svc]         # stream all output, or attach to one service (tmux)
ai-stack profile            # show active profile
ai-stack profile <name>     # switch profile (default|local|hybrid|cloud)
ai-stack shell [cmd]        # subshell with stack env + secrets loaded
ai-stack plugin  {install|upgrade|remove} <name...>
ai-stack service {install|upgrade|remove} <name...>
```

## Installation

```bash
ai-install                  # full install (bootstrap → services → plugins)
ai-install setup            # bootstrap only (prerequisites, runtimes, tooling)
ai-install services         # all services (sorted by priority)
ai-install plugins          # all plugins (sorted by priority)
```

Each component under `lib/services/` or `lib/plugins/` has an `install` script. Services also have a `launch` script (called by Overmind via Procfile).

## Profiles

| Profile | Backend | Services | Min RAM |
|---------|---------|----------|---------|
| local | rapid-mlx (Qwen3.6-35B) | headroom, litellm, rapid-mlx | 32 GB |
| max | Anthropic API + local fallback | headroom, litellm, rapid-mlx | 32 GB |
| max-direct | Anthropic API | headroom | any |
| bedrock-direct | AWS Bedrock | headroom | any |
| mistral | Ollama (Mistral Large 2 + Small 4) | headroom, ollama | 128 GB |

Switching profile copies `Procfile` (+ `litellm.yaml` + `rapid-mlx.yaml` if present) from the profile dir to runtime locations.

## Secrets

Secrets encrypted with SOPS + age. Never stored in plaintext in any committed file.

```bash
ai-secrets init             # generate age key + SOPS config
ai-secrets create           # create encrypted secrets file
ai-secrets edit             # decrypt → edit → re-encrypt
ai-secrets get <key>        # print one decrypted value
ai-secrets list             # show key names (no values)
ai-secrets show             # print all decrypted key/values
ai-secrets env              # emit export KEY=VALUE lines (used at stack start)
ai-secrets rotate           # rotate encryption keys
```

Private key: `secrets/age-key.txt` (gitignored). Encrypted file: `secrets/api-keys.sops.yaml` (gitignored).

## Models

```bash
ai-models pull              # download all from manifest
ai-models pull llm          # download a category
ai-models list              # show manifest with download status
```

Manifest: `config/models.yaml`. Models stored in `~/.cache/huggingface/hub/`.

## Service crash handling

All service `launch` scripts delegate to `lib/utils/supervised-launch`. This wrapper:
- Restarts the process up to 5 times within a 60-second window
- Uses exponential backoff: 1s → 2s → 4s → 8s → 16s (capped at 30s)
- Exits cleanly (code 1) on crash loop — Overmind marks service dead, no infinite loop
- Resets counter if process ran longer than 60s (transient failure, not crash loop)

`OVERMIND_ANY_CAN_DIE=true` — one dead service does not stop others.

## Adding a service

1. Create `lib/services/<name>/`
2. Add `install` script (idempotent)
3. Add `launch` script — must `exec` into `supervised-launch`:
   ```bash
   exec "${AI_HOME}/lib/utils/supervised-launch" <binary> [args...]
   ```
4. Add entry to relevant profile `Procfile`s
5. Optional: `priority` file (integer, lower = installed first), `remove` script, `readme.md`

## Environment variables

| Var | Default | Purpose |
|-----|---------|---------|
| `AI_HOME` | resolved from `ai-stack.env` location | project root |
| `OLLAMA_FLASH_ATTENTION` | `1` | Halves KV-cache memory on Apple Silicon |
| `OLLAMA_KV_CACHE_TYPE` | `q8_0` | Quantizes KV-cache (halves footprint again) |
| `OLLAMA_CONTEXT_LENGTH` | `200000` | Default context window for Ollama models |
| `OLLAMA_NUM_PARALLEL` | `3` | Concurrent agent request channels |
| `OLLAMA_MAX_LOADED_MODELS` | `1` | Models kept in memory simultaneously |
| `AI_STACK_AUTO_INSTALL` | `true` | run install on profile switch |
| `HEADROOM_PORT` | 8787 | token compression proxy port |
| `HEADROOM_MODE` | token | compression mode (token, cache) |
| `HEADROOM_MEMORY_PATH` | `${AI_HOME}/config/.headroom` | SQLite memory DB path |
| `CCR_PORT` | 3456 | router port |
| `ANTHROPIC_BASE_URL` | `http://localhost:8787` | Claude Code entry point |
| `ANTHROPIC_API_KEY` | `local` | placeholder key for local routing |
| `AWS_PROFILE` | sbx | AWS profile for Bedrock |
| `AWS_REGION` | eu-west-1 | AWS region |
| `ENABLE_TOOL_SEARCH` | `true` | Claude Code tool search |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 70 | auto-compaction threshold (% context) |
| `OVERMIND_PROCFILE` | `config/Procfile` | active service definitions |
| `OVERMIND_SOCKET` | `$TMPDIR/ai-stack.overmind.sock` | Overmind IPC socket |
| `OVERMIND_ANY_CAN_DIE` | true | services can die independently |

## Docs index

| Topic | File |
|-------|------|
| CLI reference | [cli.md](cli.md) |
| Profiles | [profiles.md](profiles.md) |
| Components | [components.md](components.md) |
| Integration | [integration.md](integration.md) |
| Models | [models.md](models.md) |
| Secrets | [secrets.md](secrets.md) |
| Overmind | [overmind.md](overmind.md) |
| Roadmap: Bifrost gateway | [roadmap/bifrost.md](roadmap/bifrost.md) |
| Roadmap: Groq integration | [roadmap/groq.md](roadmap/groq.md) |
