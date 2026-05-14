# Secrets

Encrypted at rest with SOPS + age. Decrypted at runtime by `ai-stack` before services start.

## File structure

```
secrets/
├── .sops.yaml              # creation rules (public key) — committed
├── age-key.txt             # private key — NEVER commit
├── api-keys.sops.yaml      # encrypted secrets — gitignored
└── sample/
    └── api-keys.sops.yaml  # template with placeholders — committed
```

## Setup

```bash
ai-secrets init      # generate age key + .sops.yaml
ai-secrets create    # create encrypted secrets file (opens $EDITOR)
```

## Runtime

`ai-stack` loads secrets at startup:

```bash
source <(ai-secrets env)
```

All keys are exported as env vars, inherited by overmind and child processes.

## Commands

See [cli.md](cli.md#ai-secrets) for full command reference.
