# Bifrost Configuration Notes

Findings from the rapid-mlx-test integration (2026-09-02). Keep for reference when adding new profiles or debugging.

## File-only mode (no SQLite DB)

Set `config_store.enabled: false` in `config.json`. Without this, bifrost creates `config.db` in its app-dir and reads provider config from there, ignoring the JSON file. Any stale DB entry can override the file and produce unexpected routing (401s, wrong model names).

If a DB exists from a prior run, delete it before testing file-only config:
```
rm config/.bifrost/config.db
```

The `-app-dir` flag in the launch script points to `config/.bifrost/`. That dir is populated at profile activation by copying the profile's `bifrost/` dir.

## Anthropic endpoint path

Bifrost does NOT expose Anthropic-format requests at `/v1/messages`. It uses a dedicated prefix:

```
POST /anthropic/v1/messages
```

headroom's `--anthropic-api-url` flag must include the `/anthropic` suffix:
```
--anthropic-api-url "http://localhost:4000/anthropic"
```

Without the suffix, requests hit bifrost's root and return `405 Method Not Allowed`.

## Custom OpenAI-compatible provider

Use `custom_provider_config.base_provider_type: "openai"` to tell bifrost to treat a named provider as an OpenAI-compatible server. Without this, bifrost treats unknown provider names as invalid.

`network_config.base_url` is the server root — bifrost appends `/v1/chat/completions` itself. Do not include the path.

Set `default_request_timeout_in_seconds: 600` for local inference; the default is too short for cold-start model loads.

## Model name mapping (aliases)

The `aliases` field on a key maps the incoming model name (what Claude Code sends) to the actual model name forwarded to the backend:

```json
"aliases": {
  "claude-sonnet-4-5": "mlx-community/...",
  "*": "mlx-community/..."
}
```

`"*"` is a catch-all. Explicit entries take precedence. Both are needed: explicit entries for models Claude Code may send, `"*"` for anything not listed.

`"models": ["*"]` on the key means the key accepts any model name (before alias resolution). Keep it as-is for single-backend profiles.

## Tool call handling (why bifrost, not litellm)

LiteLLM's `/v1/messages` path (Anthropic format proxy) strips the `tools` array before forwarding to OpenAI-compatible backends. Responses come back with `stop_reason: end_turn` and no tool calls — the model never sees the tool schemas.

Bifrost handles the Anthropic→OpenAI conversion correctly: `tools` are preserved, converted to OpenAI function-calling format, and forwarded. Responses return `stop_reason: tool_use` with proper `tool_use` content blocks.

LiteLLM's `/v1/chat/completions` (OpenAI format) does not have this bug, but headroom's `--anthropic-api-url` only supports Anthropic-format upstreams — that path is not usable with headroom.

## Per-profile config pattern

One `bifrost/config.json` per profile directory. Profile activation copies the entire `bifrost/` dir to `config/.bifrost/`, replacing any previous profile's config. This is equivalent to how `litellm.yaml` is handled.

Profiles using litellm do not have a `bifrost/` dir. Profiles using bifrost do not need `litellm.yaml`. They share port 4000 — never co-deployed.

## Overmind socket path issue

`config/ai-stack.env` sets `OVERMIND_SOCKET=$TMPDIR/ai-stack.overmind.sock`. In context-mode (`ctx-mode`), `$TMPDIR` is overridden to a per-context temp dir. Running `overmind` commands from a shell inside ctx-mode uses a different socket than the one Overmind started with. This is expected behavior — use the shell where the stack started, or kill/restart processes by PID when the socket path doesn't match.

## Version at integration time

`@maximhq/bifrost` v1.6.3, runtime v2.0.0, installed via `npx -y`.
