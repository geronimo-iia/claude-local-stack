# Repository Layout

## Structure

```
ai-stack/
├── bin/
│   ├── ai-stack                # CLI (start/stop/restart/status/enable/disable/logs)
│   ├── ai-install        # Full install orchestrator
│   └── ai-secrets              # Secrets management
│
├── config/
│   ├── ai-stack.env            # project paths (sourced by bin/ai-stack)
│   ├── Procfile                # overmind service definitions
│   └── ccr-config.json         # Claude Code Router config
│
├── lib/
│   ├── setup/                  # one-time bootstrap & core tooling
│   │   ├── prerequisites       # system deps (asdf, brew, etc.)
│   │   ├── runtimes            # language runtimes (python, node)
│   │   ├── tooling             # dev tools
│   │   └── claude-code/        # claude-code CLI install/remove
│   │
│   ├── services/               # long-running processes (have a launch script)
│   │   ├── rapid-mlx/
│   │   ├── headroom/
│   │   ├── voicemode/
│   │   ├── claude-code-router/
│   │   └── vllm-mlx/
│   │
│   ├── plugins/                # install-only extensions (no daemon)
│   │   ├── context-mode/
│   │   ├── superpowers/
│   │   ├── caveman/
│   │   ├── rtk/
│   │   ├── drawio/
│   │   └── atlassian/
│   │
│   └── utils/                  # helper scripts & dashboards
│       └── token-savings/
│
├── models/                     # all model weights (gitignored)
│   ├── llm/                    # HuggingFace cache (HF_HOME)
│   ├── whisper/                # Whisper STT
│   └── kokoro/                 # Kokoro TTS
│
├── secrets/
│   ├── .sops.yaml              # SOPS creation rules
│   ├── age-key.txt             # age private key (gitignored)
│   ├── api-keys.sops.yaml      # encrypted secrets (gitignored)
│   └── sample/
│       └── api-keys.sops.yaml  # template (committed)
│
├── logs/                       # runtime logs (gitignored)
├── docs/                       # documentation
├── .gitignore
└── README.md
```

## What's committed

| Path                         | Committed | Why                                           |
| ---------------------------- | :-------: | --------------------------------------------- |
| `bin/`                       |     ✓     | CLI scripts                                   |
| `config/`                    |     ✓     | Path definitions, service defs, router config |
| `lib/setup/`                 |     ✓     | Bootstrap scripts                             |
| `lib/services/`              |     ✓     | Service install/launch scripts                |
| `lib/plugins/`               |     ✓     | Plugin install/remove scripts                 |
| `lib/utils/`                 |     ✓     | Helper scripts                                |
| `secrets/.sops.yaml`         |     ✓     | SOPS rules (public key only)                  |
| `secrets/sample/`            |     ✓     | Template for new users                        |
| `docs/`                      |     ✓     | Documentation                                 |
| `models/`                    |     ✗     | Large files, downloaded locally               |
| `lib/services/*/.venv/`      |     ✗     | Recreated via `uv venv`                       |
| `secrets/age-key.txt`        |     ✗     | Private key                                   |
| `secrets/api-keys.sops.yaml` |     ✗     | Encrypted secrets                             |
| `logs/`                      |     ✗     | Runtime output                                |

## Runtime artifacts (not in repo)

| Artifact        | Location                         | Purpose                   |
| --------------- | -------------------------------- | ------------------------- |
| Overmind socket | `$TMPDIR/ai-stack.overmind.sock` | IPC for overmind commands |
| PID tracking    | Managed by overmind internally   | —                         |
| Logs            | `logs/`                          | Service output            |

## Symlinks to system locations

```bash
# CCR expects config here
ln -sf <repo>/config/ccr-config.json ~/.claude-code-router/config.json
```
