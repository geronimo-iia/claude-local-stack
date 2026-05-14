# ai-stack

Local AI development stack. Routes LLM requests through a proxy chain to local models (MLX) or cloud (Bedrock).

## Call chain

```
Claude Code → Headroom (:8787) → CCR (:3456) → rapid-mlx (:8000) / Bedrock
```

| Component | Role                               |
| --------- | ---------------------------------- |
| Headroom  | Token compression proxy            |
| CCR       | Multi-provider router (task-based) |
| rapid-mlx | Local MLX inference server         |
| Bedrock   | AWS cloud fallback                 |

## Quick start

```bash
ai-install              # install everything
ai-stack profile default  # activate a profile
ai-stack start          # boot services
ai-stack shell          # open shell with env loaded, then run: claude
```

## Integration

Point any tool at `http://localhost:8787` with `ANTHROPIC_API_KEY=local`.

These are exported automatically by `ai-stack shell`:
```bash
ANTHROPIC_BASE_URL=http://localhost:8787
ANTHROPIC_API_KEY=local
```

## Repository layout

```
ai-stack/
├── bin/                        # CLI tools (ai-stack, ai-install, ai-secrets, ai-models)
├── config/
│   ├── ai-stack.env            # project paths (AI_HOME, SOPS_AGE_KEY_FILE)
│   ├── Procfile                # active service definitions (copied from profile)
│   ├── rapid-mlx.yaml          # active rapid-mlx config (copied from profile)
│   ├── .active-profile         # current profile name
│   └── profiles/               # profile definitions (see profiles.md)
├── lib/
│   ├── setup/                  # bootstrap scripts (prerequisites, runtimes, tooling)
│   ├── services/               # long-running daemons (rapid-mlx, headroom, ccr, ...)
│   ├── plugins/                # install-only extensions (rtk, context-mode, ...)
│   └── utils/                  # helper scripts
├── secrets/                    # SOPS-encrypted API keys (see secrets.md)
├── logs/                       # runtime logs (gitignored)
└── docs/
```

## What's gitignored

- `secrets/age-key.txt` — private key
- `secrets/api-keys.sops.yaml` — encrypted secrets
- `config/.active-profile` — runtime state
- `logs/` — runtime output
- `lib/services/*/.venv/` — recreated via install
