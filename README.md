# ai-stack

Local AI stack for Claude Code on Apple Silicon. Fully offline multi-model routing, token compression, voice, and prompt optimization.

## Architecture

```
Claude Code → Headroom (:8787) → CCR (:3456) → rapid-mlx (:8000-8002) / Bedrock
```

| Component | Role                       | Port      |
| --------- | -------------------------- | --------- |
| Headroom  | Token compression proxy    | 8787      |
| CCR       | Multi-provider task router | 3456      |
| rapid-mlx | Local MLX inference        | 8000-8002 |
| Bedrock   | AWS cloud fallback         | —         |

## Quick start

```bash
# Prerequisites
# - macOS Apple Silicon (M3 Max 128 GB recommended)
# - asdf (plugins: python, nodejs, uv)
# - overmind + tmux
# - sops + age

# Install
ai-install
ai-models pull

# Activate a profile, boot, and launch Claude
ai-stack profile default
ai-stack start
ai-stack shell
claude
```

## Profiles

Switch routing strategy, models, and services per workflow.

| Profile | Local models             | Cloud fallback | Services                          |
| ------- | ------------------------ | -------------- | --------------------------------- |
| default | Yes (Qwen3.6-35B)        | No             | headroom, ccr, rapid-mlx          |
| local   | Yes (Qwen3.6, 27B, 235B) | No             | headroom, ccr, rapid-mlx x3       |
| hybrid  | Yes                      | Bedrock        | headroom, ccr, rapid-mlx, Bedrock |
| cloud   | No                       | Bedrock        | ccr, Bedrock                      |

```bash
ai-stack profile hybrid   # switch profile
ai-stack profile          # show current
```

See [docs/profiles.md](docs/profiles.md) for routing matrix and details.

## CLI reference

### Stack management

```bash
ai-stack start              # start all services
ai-stack stop               # stop all
ai-stack restart [svc]      # restart all or one
ai-stack status             # running processes
ai-stack logs [svc]         # stream or attach logs
ai-stack enable <svc...>    # uncomment service, restart if running
ai-stack disable <svc...>   # comment service, restart if running
ai-stack shell              # subshell with env + secrets loaded
```

### Installation

```bash
ai-install                  # full install
ai-install headroom rtk     # cherry-pick by name
ai-install --list           # available components
```

### Secrets

```bash
ai-secrets init             # generate age key + SOPS config
ai-secrets edit             # decrypt → edit → re-encrypt
ai-secrets get <key>        # print one value
ai-secrets show             # show all
ai-secrets rotate           # rotate keys
```

### Models

```bash
ai-models pull              # download all
ai-models pull llm          # download a category
ai-models list              # show manifest + status
```

See [docs/cli.md](docs/cli.md) for full reference.

## Integration

Point any tool at `http://localhost:8787` with `ANTHROPIC_API_KEY=local`.

| Tool                 | Config                                                                   |
| -------------------- | ------------------------------------------------------------------------ |
| Claude Code CLI      | `ai-stack shell` then `claude`                                           |
| VS Code + Continue   | `.continue/config.yaml` — see [docs/integration.md](docs/integration.md) |
| VS Code + Claude ext | `settings.json` — see [docs/integration.md](docs/integration.md)         |

## Repository layout

```
ai-stack/
├── bin/              # CLI tools (ai-stack, ai-install, ai-secrets, ai-models)
├── config/
│   ├── ai-stack.env  # project paths
│   ├── profiles/     # profile definitions (default, local, hybrid, cloud)
│   ├── Procfile      # active service definitions
│   └── models.yaml   # model manifest
├── lib/
│   ├── setup/        # bootstrap scripts
│   ├── services/     # daemons (rapid-mlx, headroom, ccr)
│   ├── plugins/      # extensions (rtk, context-mode, superpowers, caveman, drawio, atlassian)
│   └── utils/        # helpers
├── secrets/          # SOPS-encrypted keys
├── logs/             # runtime logs (gitignored)
└── docs/
```

## What's gitignored

- `secrets/age-key.txt` — private key
- `secrets/api-keys.sops.yaml` — encrypted secrets
- `config/.active-profile` — runtime state
- `logs/` — runtime output
- `lib/services/*/.venv/` — recreated via install

## Docs

| Topic         | File                                           |
| ------------- | ---------------------------------------------- |
| CLI           | [docs/cli.md](docs/cli.md)                     |
| Profiles      | [docs/profiles.md](docs/profiles.md)           |
| Components    | [docs/components.md](docs/components.md)       |
| Integration   | [docs/integration.md](docs/integration.md)     |
| Models        | [docs/models.md](docs/models.md)               |
| Secrets       | [docs/secrets.md](docs/secrets.md)             |
| Test protocol | [docs/test-protocol.md](docs/test-protocol.md) |