# CLI

## ai-stack

Stack lifecycle and profile management.

```bash
ai-stack start              # start all services (daemonized)
ai-stack stop               # stop all services
ai-stack restart [svc]      # restart all or one service
ai-stack status             # show running processes
ai-stack enable <svc...>    # uncomment service in Procfile, restart if running
ai-stack disable <svc...>   # comment service in Procfile, restart if running
ai-stack logs [svc]         # stream all output, or attach to one service
ai-stack shell              # open subshell with stack env + secrets loaded
ai-stack profile            # show current profile
ai-stack profile <name>     # switch profile (default|local|hybrid|cloud)
ai-stack plugin  {install|upgrade|remove} <name...>   # manage Claude Code plugins
ai-stack service {install|upgrade|remove} <name...>   # manage services and setup components
```

`enable`/`disable` are runtime overrides on the active Procfile. Switching profile resets the Procfile.

## ai-install

Bootstrap only. Installs all components in order; use `ai-stack plugin/service` for day-to-day per-component ops.

```bash
ai-install                  # full install (setup → services → plugins)
ai-install setup            # bootstrap only (prerequisites, runtimes, tooling)
ai-install services         # all services (sorted by priority)
ai-install plugins          # all plugins (sorted by priority)
```

Install order within a category is controlled by `priority` file (lower = first, default 50).

## ai-secrets

SOPS + age encrypted secrets.

```bash
ai-secrets init             # generate age key + SOPS config
ai-secrets create           # create encrypted secrets file
ai-secrets edit             # decrypt → editor → re-encrypt
ai-secrets get <key>        # print one decrypted value
ai-secrets list             # show key names (no values)
ai-secrets show             # show all decrypted key/values
ai-secrets env              # output as export KEY=VALUE lines
ai-secrets rotate           # rotate encryption keys
```

Secrets are loaded automatically by `ai-stack` at startup via `source <(ai-secrets env)`.

## ai-models

Model download management.

```bash
ai-models pull              # download all models from manifest
ai-models pull llm          # download a category
ai-models pull <repo-id>    # download a specific model
ai-models list              # show manifest with download status
```

Models declared in `config/models.yaml`. Stored in HuggingFace cache (`~/.cache/huggingface/hub/`).
