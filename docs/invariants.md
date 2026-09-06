# Invariants

Rules that must hold at all times. Breaking any of these causes silent failures, crashes, or security issues.

## Config

**`config/Procfile` is generated state.** Never edit it directly — it is overwritten on every profile switch. Always edit the profile source at `config/profiles/<name>/Procfile`.

**Bifrost config must never contain a `config_store` block.** Bifrost v2.0.0 crashes on startup if any `config_store` key is present, even `{"enabled": false}`. The block must be absent entirely.

**Bifrost secrets use `"env.VAR_NAME"` syntax.** Never inline credentials in `config.json`. Bifrost resolves env references at startup from the process environment.

**`config/.env` is sourced last.** It overrides everything. It is gitignored and must never be committed.

## Boot order

**`AI_HOME` is set before anything else.** Every script, util, and service depends on it. `config/ai-stack.env` resolves it from its own file location — source that file first.

**`load-service-env` requires `AI_HOME`.** Always source `ai-stack.env` before calling `load-service-env`.

**`asdf` reads `.tool-versions` from the current directory.** Scripts that invoke asdf-managed binaries must `cd "${AI_HOME}"` before the call (or before exec). `ai-install` does this automatically.

## Service contract

**`install` scripts are idempotent.** `ai-stack service install <name>` can be called any number of times without side effects. Each run must leave the component in a valid installed state.

**`install` scripts handle four cases via `$1`: `install`, `upgrade`, `remove`, `check`.** The `ai-stack` CLI passes these as the first argument. Missing a case causes `ai-stack service install/check/remove` to silently do nothing or error.

**`launch` scripts source `ai-stack.env` + `load-service-env` before `exec`.** A launch script that skips this starts the daemon with an incomplete environment. Service-specific vars (`HEADROOM_MODE`, `OLLAMA_KEEP_ALIVE`, AWS credentials, etc.) are absent.

**`supervised-launch` is the only restart mechanism.** Overmind auto-restart is deliberately disabled (`OVERMIND_AUTO_RESTART` not set). Never rely on overmind to restart a crashed service — it won't.

## Profiles

**A profile must be active before `ai-stack install` or `ai-stack check`.** Both commands read `config/.active-profile`. Without it they cannot know which `services.yaml` to use.

**`enable`/`disable` are runtime-only overrides.** They modify the active `config/Procfile`. A profile switch resets the Procfile — any enable/disable changes are lost.

## Security

**`ANTHROPIC_API_KEY=local` is a sentinel value.** Headroom intercepts all requests at port 8787 and routes them to the active backend. The string `"local"` is never forwarded to any provider.

**AWS credentials belong in `config/profiles/<profile>/<svc>.env`.** These files are gitignored. Never put AWS keys, tokens, or any credential in `ai-stack.env`, `default.env`, or any committed file.

**`secrets/age-key.txt` and `secrets/api-keys.sops.yaml` are gitignored.** If either file appears in `git status`, do not commit — abort and investigate.
