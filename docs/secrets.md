# Secrets Management

Secrets are encrypted at rest with [SOPS](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age). Managed via `bin/ai-secrets`. Decrypted at runtime by `bin/ai-stack` before services start.

See [prerequisites](prerequisites.md) for installation.

## Setup

### Initialize (first time)

```bash
ai-secrets init
```

Generates `secrets/age-key.txt` and `secrets/.sops.yaml` in one step.

### Create secrets

```bash
ai-secrets create
```

Opens your `$EDITOR` in cleartext. On save, SOPS encrypts values:

```yaml
anthropic_api_key: sk-ant-...
```

## Commands

```bash
ai-secrets init                    # generate age key + SOPS config
ai-secrets create                  # create encrypted secrets file
ai-secrets edit                    # decrypt → editor → re-encrypt
ai-secrets get <key>               # print a single decrypted value
ai-secrets list                    # show key names (no values)
ai-secrets show                    # show all decrypted key/values
ai-secrets env                     # output as KEY=VALUE lines (for eval)
ai-secrets rotate                  # rotate encryption keys
```

## How it integrates with ai-stack

`bin/ai-stack` loads secrets before starting services:

```bash
eval "$(ai-secrets env)"
```

This exports all keys as env vars, inherited by overmind and all child processes. If no secrets file exists, it's a silent no-op.

You can use the same pattern in any script:

```bash
eval "$(ai-secrets env)"
echo "$anthropic_api_key"
```

## File structure

```
secrets/
├── .sops.yaml              # creation rules (public key) — committed
├── age-key.txt             # private key — NEVER commit
├── api-keys.sops.yaml      # encrypted secrets — gitignored
└── sample/
    └── api-keys.sops.yaml  # template with placeholder values — committed
```

## Security rules

- `age-key.txt` — never commit (in `.gitignore`)
- `api-keys.sops.yaml` — gitignored (encrypted, but no reason to share)
- `sample/` — committed (placeholder values only, reference for new users)
- `.sops.yaml` — committed (contains only the public key)
