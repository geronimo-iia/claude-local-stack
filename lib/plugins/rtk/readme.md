# RTK — Bash Output Compression

Source: https://github.com/rtk-ai/rtk

Rust binary that intercepts bash command output via a PreToolUse hook.
Claude Code never sees raw output — only RTK's compressed version.
Transparent: Claude Code doesn't know RTK exists.

## How it works

Every bash command output gets silently compressed:
- `git status` → compressed diff output
- `cargo test` → filtered test results
- `npm install` → stripped progress bars
- `docker logs` → trimmed to relevant lines

Savings: 60–90% on every tool call.

## What `rtk init --global` writes

`~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "rtk hook claude" }]
      }
    ]
  }
}
```

## Commands

```bash
rtk gain              # token savings stats
rtk discover          # which commands benefit most
rtk config            # show current configuration
rtk config --create   # create config file with defaults
```

## Configuration

https://github.com/rtk-ai/rtk/blob/develop/docs/guide/getting-started/configuration.md

## Telemetry

https://github.com/rtk-ai/rtk/blob/develop/docs/guide/resources/telemetry.md
