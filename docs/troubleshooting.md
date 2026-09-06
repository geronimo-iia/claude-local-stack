# Troubleshooting

## Port already in use

**Symptom:** service fails to start with `address already in use` on port 8787 or 4000.

A previous process is still holding the port — overmind restart alone does not kill it.

```bash
# Find and kill the process holding the port
lsof -ti :8787 | xargs kill -9
lsof -ti :4000 | xargs kill -9

ai-stack restart headroom
ai-stack restart bifrost
```

## Headroom crash loop

**Symptom:** `ai-stack status` shows headroom dead; logs show repeated restarts then exit.

`supervised-launch` stops after 5 crashes within 60 seconds. Most common causes:

1. Port conflict — see above
2. Missing `HEADROOM_MEMORY_PATH` directory:
   ```bash
   mkdir -p "${AI_HOME}/config/.headroom"
   ai-stack restart headroom
   ```
3. Incompatible `--mode` flag — check `lib/services/headroom/default.env` matches the installed headroom version

## Bifrost not starting

**Symptom:** bifrost exits immediately; logs show JSON parse error or `unknown field`.

Check `config/.bifrost/config.json` for the `config_store` block — bifrost v2.0.0 rejects it:

```bash
# Should return nothing
grep -r "config_store" "${AI_HOME}/config/.bifrost/"
grep -r "config_store" "${AI_HOME}/config/profiles/"
```

If found, remove the entire `"config_store": {...}` block from the affected file.

Also verify the active profile's `bifrost/config.json` was copied correctly:

```bash
cat "${AI_HOME}/config/.bifrost/config.json"
```

If stale, re-activate the profile: `ai-stack profile $(cat config/.active-profile) --force`

## AWS credentials expired (bedrock profile)

**Symptom:** bifrost returns 403 or `InvalidSignatureException` on bedrock profile; requests fail after a few hours.

STS session tokens from `aws configure export-credentials` expire (typically 1–8 hours for SSO).

The `config/profiles/bedrock/bifrost.env` file re-exports credentials at service start via `eval "$(aws configure export-credentials ...)"` — **restart bifrost to refresh**:

```bash
ai-stack restart bifrost
```

If still failing, check the SSO session is still valid:

```bash
aws sts get-caller-identity --profile your-profile
# If expired:
aws sso login --profile your-profile
ai-stack restart bifrost
```

## `overmind` client commands fail

**Symptom:** `overmind ps` or `overmind restart` returns `connect: no such file or directory`.

`OVERMIND_SOCKET` is not set in the current shell. Source the stack env first:

```bash
source "${AI_HOME}/config/ai-stack.env"
overmind ps
```

Or use the `ai-stack` wrappers which source the env automatically:

```bash
ai-stack status
ai-stack restart bifrost
```

## No active profile

**Symptom:** `ai-stack install`, `ai-stack check`, or services fail with "no active profile".

```bash
ai-stack profile            # check current
ai-stack profile local      # activate one
```

## Stack starts but Claude Code can't connect

**Symptom:** Claude Code returns connection refused or timeouts.

1. Verify headroom is running: `ai-stack status`
2. Verify `ANTHROPIC_BASE_URL` is set to `http://localhost:8787`:
   ```bash
   echo $ANTHROPIC_BASE_URL
   ```
3. If running Claude Code outside `ai-stack shell`, source the env manually:
   ```bash
   source "${AI_HOME}/config/ai-stack.env"
   claude
   ```
   Or use the alias: `aclaude`

## Logs

```bash
ai-stack logs               # all services (stream)
ai-stack logs headroom      # attach to one service (tmux pane)
ls logs/                    # persistent log files
```

Detach from tmux: `Ctrl+B` then `D`.
