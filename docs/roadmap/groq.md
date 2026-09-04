# Roadmap: Groq Integration

Groq is an OpenAI-compatible inference API (Llama, Qwen, Mixtral models). Very low latency,
generous free tier, pay-per-token after that. Integrates via LiteLLM — same mechanism used
in the `max` profile.

Groq does NOT host Claude models. Claude Code will receive Llama/Qwen responses when Groq
is active. Tool use works. Quality varies by model — Qwen QwQ 32B is competitive for
reasoning and coding; Llama 70B is solid for general tasks.

## Rate Limits (2026)

| Tier | RPM   | TPM (llama-3.3-70b) |
| ---- | ----- | ------------------- |
| Free | 30    | 6,000               |
| Paid | 1,000 | 100,000+            |

Claude Code burns free-tier TPM in one heavy turn. Groq is useful as a fallback, not a
primary for intensive sessions. Paid tier is viable for secondary workloads.

## Secret

Add `GROQ_API_KEY` to the encrypted secrets file:

```bash
ai-secrets edit   # adds key → re-encrypts → injected via source <(ai-secrets env)
```

```yaml
# secrets/api-keys.sops.yaml (decrypted view)
GROQ_API_KEY: gsk_...
```

LiteLLM reads it as `os.environ/GROQ_API_KEY`. No plaintext anywhere.

## Profile Matrix

| Profile    | Anthropic | Groq         | local (rapid-mlx) |
| ---------- | --------- | ------------ | ----------------- |
| `max`      | primary   | —            | offline fallback  |
| `max-groq` | primary   | default slot | offline fallback  |
| `groq`     | —         | primary      | offline fallback  |

Switching provider mix = switching profile. LiteLLM handles local failures automatically
— if rapid-mlx is stopped, requests fall through to the next configured provider with no
manual intervention.

## Option A — Max + Groq Tiered Routing

Claude Code already signals task complexity via the model it requests. LiteLLM maps each
model name to the appropriate provider — Groq handles background and default tasks, Anthropic
handles heavy reasoning, local MLX is the offline fallback.

```
claude-haiku-4-5  → Groq llama-3.1-8b-instant   (background — speed)
claude-sonnet-4-6 → Groq qwen-qwq-32b            (default — quality)
claude-opus-5     → Anthropic Max                 (heavy reasoning — no substitute)
                     + Groq fallback on 429
                     + rapid-mlx offline fallback
```

Update `config/profiles/max/litellm.yaml`:

```yaml
model_list:
  # Background tasks → Groq fast model
  - model_name: claude-haiku-4-5
    litellm_params:
      model: groq/llama-3.1-8b-instant
      api_key: os.environ/GROQ_API_KEY

  # Default tasks → Groq Qwen QwQ (strong reasoning/coding)
  - model_name: claude-sonnet-4-6
    litellm_params:
      model: groq/qwen-qwq-32b
      api_key: os.environ/GROQ_API_KEY

  # Groq fallback for sonnet (429 / rate limit)
  - model_name: claude-sonnet-4-6-groq-fallback
    litellm_params:
      model: groq/llama-3.3-70b-versatile
      api_key: os.environ/GROQ_API_KEY

  # Heavy reasoning → Anthropic Max only
  - model_name: claude-opus-5
    litellm_params:
      model: anthropic/claude-opus-5
      api_key: os.environ/ANTHROPIC_API_KEY

  # Anthropic fallback for opus (429)
  - model_name: claude-opus-5-groq-fallback
    litellm_params:
      model: groq/qwen-qwq-32b
      api_key: os.environ/GROQ_API_KEY

  # Offline fallback
  - model_name: local
    litellm_params:
      model: openai/qwen
      api_base: http://localhost:8000
      api_key: local

router_settings:
  fallbacks:
    - claude-sonnet-4-6: [claude-sonnet-4-6-groq-fallback, local]
    - claude-opus-5: [claude-opus-5-groq-fallback, local]
  retry_policy:
    RateLimitErrorRetries: 1
  num_retries: 2

litellm_settings:
  request_timeout: 600
  telemetry: false
```

No changes to Procfile or headroom launch — LiteLLM already in the path.

**If you want Anthropic as primary for default tasks** (Groq only as fallback):

```yaml
  - model_name: claude-sonnet-4-6
    litellm_params:
      model: anthropic/claude-sonnet-4-6
      api_key: os.environ/ANTHROPIC_API_KEY

  - model_name: claude-sonnet-4-6-groq-fallback
    litellm_params:
      model: groq/qwen-qwq-32b
      api_key: os.environ/GROQ_API_KEY
```

## Option B — `groq` Profile (no Anthropic)

Groq primary, local fallback. Fully Anthropic-free — useful when
you want zero Anthropic spend or are testing without a Max key.

```
Claude Code → Headroom → LiteLLM → rapid-mlx   (primary — local Qwen)
                                  → Groq         (fallback — local overloaded / error)
```

### Profile layout

```
config/profiles/groq/
├── litellm.yaml
├── Procfile
└── readme.md
```

`config/profiles/groq/litellm.yaml`:

```yaml
model_list:
  - model_name: default
    litellm_params:
      model: openai/qwen
      api_base: http://localhost:8000
      api_key: local

  - model_name: default-groq
    litellm_params:
      model: groq/qwen-qwq-32b
      api_key: os.environ/GROQ_API_KEY

router_settings:
  fallbacks:
    - default: [default-groq]
  retry_policy:
    RateLimitErrorRetries: 1
  num_retries: 1

litellm_settings:
  request_timeout: 600
  telemetry: false
```

`config/profiles/groq/Procfile`:

```
rapid-mlx: ${AI_HOME}/lib/services/rapid-mlx/launch
litellm:   ${AI_HOME}/lib/services/litellm/launch
headroom:  ${AI_HOME}/lib/services/headroom/launch-litellm
```

`lib/services/headroom/launch-litellm` (new, mirrors `launch` with LiteLLM target):

```bash
#!/bin/zsh
set -euo pipefail
[[ -z "${AI_HOME:-}" ]] && source "$(dirname "$0")/../../../config/ai-stack.env"

exec "${AI_HOME}/lib/utils/supervised-launch" \
  "headroom" proxy \
  --port "${HEADROOM_PORT:-8787}" \
  --mode "${HEADROOM_MODE:-token}" \
  --anthropic-api-url "http://localhost:${LITELLM_PORT:-4000}" \
  --no-telemetry \
  --no-subscription-tracking \
  --workers "${HEADROOM_WORKERS:-1}" \
  --memory \
  --memory-db-path "${HEADROOM_MEMORY_PATH}/memory.db" \
  --log-file "${AI_HOME}/logs/headroom-$(date +%Y-%m-%d).log"
```

**Tradeoff vs max profile:** Qwen3.6-35B local is roughly comparable to Qwen QwQ 32B on
Groq for coding tasks. Groq fallback adds value when local is slow (thermal throttle, memory
pressure) or you want a cloud backup without Anthropic spend.

## Model Choice

| Model                          | Task tier               | Notes                                                |
| ------------------------------ | ----------------------- | ---------------------------------------------------- |
| `groq/qwen-qwq-32b`            | Default (sonnet slot)   | Strong reasoning and coding — primary Groq workhorse |
| `groq/llama-3.3-70b-versatile` | Default fallback        | Fast general model when QwQ is rate-limited          |
| `groq/llama-3.1-8b-instant`    | Background (haiku slot) | Speed-optimised, acceptable for simple subtasks      |

## Secrets Required

Add to `secrets/api-keys.sops.yaml` via `ai-secrets edit`:

```yaml
GROQ_API_KEY: gsk_...
```

No other credential changes. `ANTHROPIC_API_KEY` already present for option A.
Option B requires no Anthropic key.

## Migration Trigger

**Option A:** implement when Max plan is active and Anthropic rate limiting becomes a daily
friction point.

**Option B:** implement when you want an Anthropic-free fallback during Max plan outages,
or want to test Groq quality for specific task types before using it in production.

