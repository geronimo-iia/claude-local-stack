# claude-local-stack

> **Requires Apple Silicon (M1/M2/M3/M4)** — MLX inference is ARM-only. macOS only.

Local AI stack for Claude Code on Apple Silicon.
Configuration per profile:
- offline mono or multi-model routing,
- cloud
With token optimization

Since I work with many llm model and tool, it was time for me to try to manage all the mess in a more rational way.
This stack is far from state of the art, but it help me a lot for :
- my daily job
- encrypt secret (and don't wrote them everywhere ...)
- manage token compression, plugins configuration
- start playing with voice (STT/TTS) integration
- experimenting model

I know that my installation and scripts are macos only...
But with the help of an agent and local docs, i'm sure that you could translate all this stack for your personal computer.


## Architecture

### Default Profile (fully local)

```mermaid
flowchart LR
    CC[Claude Code] --> H[Headroom :8787]
    H --> B[Bifrost :4000]
    B --> R[rapid-mlx :8000]
    R --> M[Qwen3.6-35B-A3B MLX]
```

### Max Profile (Anthropic API via Claude Max plan)

```mermaid
flowchart LR
    CC[Claude Code] --> H[Headroom :8787]
    H --> B[Bifrost :4000]
    B --> A[Anthropic API]
    A --> Claude[Claude Sonnet/Opus]
```

### Cloud Profile (AWS Bedrock)

```mermaid
flowchart LR
    CC[Claude Code] --> H[Headroom :8787]
    H --> B[Bifrost :4000]
    B --> BK[AWS Bedrock]
    BK --> Claude[Claude Sonnet/Opus]
```

### Components

| Component                                           | Role                    | Port  |
| --------------------------------------------------- | ----------------------- | ----- |
| [Headroom](https://github.com/nicobailon/headroom)  | Token compression proxy | 8787  |
| [Bifrost](https://www.getbifrost.ai)                | Multi-provider gateway  | 4000  |
| [rapid-mlx](https://github.com/argmaxinc/rapid-mlx) | Local MLX inference     | 8000+ |
| [AWS Bedrock](https://aws.amazon.com/bedrock/)      | Cloud LLM provider      | —     |

### Claude Plugins

| Plugin                                                  | Role                                      |
| ------------------------------------------------------- | ----------------------------------------- |
| [RTK](https://github.com/nicobailon/rtk)                | Token saving — shell command compression  |
| [caveman](https://github.com/cyanheads/caveman)         | Token saving — output compression         |
| [context-mode](https://github.com/mksglu/context-mode)  | Token saving — context management         |
| superpowers                                             | Skills framework — workflows and checklists |
| agent-skills                                            | Agentic task skills                       |
| andrej-karpathy-skills                                  | ML/research skills                        |
| llm-wiki-skills                                         | Wiki ingest, research, crystallize (MCP)  |
| rust-analyzer-lsp                                       | Rust LSP integration                      |
| drawio                                                  | Diagram editing (occasional)              |
| [atlassian](https://claude.com/plugins/atlassian)       | Jira/Confluence integration (occasional)  |

### Stack Technologies

| Tool                                                                                | Role                     | Link        |
| ----------------------------------------------------------------------------------- | ------------------------ | ----------- |
| [asdf](https://github.com/asdf-vm/asdf)                                             | Runtime version manager  | plugins     |
| [uv](https://github.com/astral-sh/uv)                                               | Python package manager   | venvs       |
| [Homebrew](https://github.com/Homebrew/brew)                                        | macOS package manager    | formulae    |
| [overmind](https://github.com/DarthSim/overmind)                                    | Procfile process manager | tmux-backed |
| [SOPS](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age) | Secrets encryption       | —           |

### Stack Runtimes

| Runtime                                            | Managed via | Notes                       |
| -------------------------------------------------- | ----------- | --------------------------- |
| [Python 3.12.x](https://github.com/python/cpython) | asdf        | ML compatibility            |
| [Node 22.x LTS](https://github.com/nodejs/node)    | asdf        | Claude Code / Bifrost       |
| [Rust](https://github.com/rust-lang/rust)          | asdf        | needed for some Python deps |


## Quick start

1. Clone: `cd $HOME && git clone <repo> claude-local-stack`
2. [Configure your shell](./docs/integration.md#shell) — add `AI_HOME`, `PATH`, aliases to `~/.zshrc`/`~/.zshenv`
3. Bootstrap: `ai-install` (prerequisites, runtimes, tooling)
4. Set secrets: `ai-secrets init` then `ai-secrets edit` — add `ANTHROPIC_API_KEY`, `HF_TOKEN`, etc.
5. Activate a profile: `ai-stack profile local`
6. Install profile deps: `ai-stack install`
7. Start the stack: `ai-stack start`
8. Launch Claude: `aclaude`, or VS Code: `acode`

If anything goes wrong: see [docs/troubleshooting.md](docs/troubleshooting.md).


## Profiles

Switch routing strategy, models, and services per workflow:

- `local`: [local only](./config/profiles/local/readme.md) — no cloud account needed
- `bedrock`: [AWS Bedrock](./config/profiles/bedrock/readme.md) — requires AWS CLI configured with Bedrock access
- `max`: [Anthropic API](./config/profiles/max/readme.md) — requires Anthropic API key


```bash
ai-stack profile local   # switch profile
ai-stack profile          # show current
```

See [docs/profiles.md](docs/profiles.md) for routing matrix and details.

## CLI reference

See [docs/cli.md](docs/cli.md) for full reference.

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
ai-stack check [profile]    # dep report for active (or named) profile
ai-stack install [profile]  # install all missing deps
```

### Installation

```bash
ai-install                  # bootstrap (prerequisites, runtimes, tooling)
ai-stack install            # install services + plugins for active profile
ai-stack install <profile>  # install for a named profile without switching
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

Even if this client sit on top of hf (hugging face), I still like to see somewhere a list of my [model](./config/models.yaml) than I use ...
This cli use hugging face local cache to store them, as most of our tool use it, it fix my fears....

```bash
ai-models pull              # download all
ai-models pull llm          # download a category
ai-models list              # show manifest + status
```

See [docs/cli.md](docs/cli.md) for full reference.

## Integration

Point any tool at `http://localhost:8787` with `ANTHROPIC_API_KEY=local`.

> `ANTHROPIC_API_KEY=local` is a sentinel value — Headroom intercepts requests at port 8787 and routes them to the active profile backend. No real Anthropic key is sent when using local/Bedrock profiles.

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
│   ├── ai-stack.env        # project paths
│   ├── base-services.yaml  # universal deps (claude-code, superpowers, overmind)
│   ├── profiles/           # profile definitions (local, bedrock, bedrock-direct, max, mistral, …)
│   ├── Procfile            # active service definitions
│   └── models.yaml         # model manifest
├── lib/
│   ├── setup/        # one-shot bootstrap scripts (prerequisites, runtimes, tooling)
│   ├── services/     # daemons: rapid-mlx, bifrost, headroom, ollama, voicemode; tools: llm-wiki
│   ├── plugins/      # Claude Code plugins (rtk, context-mode, superpowers, caveman, agent-skills…)
│   └── utils/        # helpers (supervised-launch, load-service-env, token-savings)
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

| Topic           | File                                                   |
| --------------- | ------------------------------------------------------ |
| CLI             | [docs/cli.md](docs/cli.md)                             |
| Profiles        | [docs/profiles.md](docs/profiles.md)                   |
| Components      | [docs/components.md](docs/components.md)               |
| Integration     | [docs/integration.md](docs/integration.md)             |
| Models          | [docs/models.md](docs/models.md)                       |
| Secrets         | [docs/secrets.md](docs/secrets.md)                     |
| Overmind        | [docs/overmind.md](docs/overmind.md)                   |
| Troubleshooting | [docs/troubleshooting.md](docs/troubleshooting.md)     |
