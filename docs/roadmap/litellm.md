# Roadmap: LiteLLM as Multi-Provider Router

## Context

When the stack gains three active providers — local Ollama, personal AWS Bedrock, and Anthropic API — CCR becomes limiting. It routes by task type but has no concept of fallback, cross-provider cost tracking, or dynamic switching.

LiteLLM is the natural replacement for CCR at that point. Headroom stays untouched — it remains the entry point for Claude Code regardless of what router sits behind it.

## Target Architecture

```
Claude Code → Headroom (:8787) → LiteLLM (:4000) → Ollama (:11434)        [local]
                                                   → AWS Bedrock            [cloud]
                                                   → Anthropic API          [cloud]
```

## Routing Strategy

| Route | Model | Provider | Rationale |
|-------|-------|----------|-----------|
| `background` | mistral-small:24b | Ollama | Free, fast, good enough for subtasks |
| `default` | mistral-large:123b | Ollama | Free, capable for most coding tasks |
| `think` | claude-sonnet-4-5 | Bedrock | Heavy reasoning, AWS billing |
| `longContext` | claude-sonnet-4-5 | Bedrock | Large context, AWS billing |
| `webSearch` | claude-opus-4-5 | Anthropic API | Full capability, direct API billing |

## What to Add to the Stack

### 1. Service — `lib/services/litellm/`

```
lib/services/litellm/
├── install      # uv tool install litellm
├── launch       # supervised-launch litellm --config ${AI_HOME}/config/litellm.yaml --port ${LITELLM_PORT}
├── priority     # 15 (same as ollama — before CCR)
└── readme.md
```

### 2. Profile — `config/profiles/multi/`

```
config/profiles/multi/
├── ccr.json         # not needed — LiteLLM replaces CCR
├── litellm.yaml     # → config/litellm.yaml on activation
├── Procfile         # ollama + litellm + headroom (no ccr)
├── services.yaml    # ollama + litellm + headroom
└── readme.md
```

`Procfile`:
```
ollama:   ${AI_HOME}/lib/services/ollama/launch
litellm:  ${AI_HOME}/lib/services/litellm/launch
headroom: ${AI_HOME}/lib/services/headroom/launch
```

### 3. Config — `config/litellm.yaml`

Copied from `config/profiles/multi/litellm.yaml` on profile activation.

```yaml
model_list:
  - model_name: background
    litellm_params:
      model: ollama/mistral-small:24b
      api_base: http://localhost:11434

  - model_name: default
    litellm_params:
      model: ollama/mistral-large:123b
      api_base: http://localhost:11434

  - model_name: think
    litellm_params:
      model: bedrock/anthropic.claude-sonnet-4-5
      aws_access_key_id: os.environ/AWS_ACCESS_KEY_ID
      aws_secret_access_key: os.environ/AWS_SECRET_ACCESS_KEY
      aws_region_name: os.environ/AWS_REGION

  - model_name: longContext
    litellm_params:
      model: bedrock/anthropic.claude-sonnet-4-5
      aws_access_key_id: os.environ/AWS_ACCESS_KEY_ID
      aws_secret_access_key: os.environ/AWS_SECRET_ACCESS_KEY
      aws_region_name: os.environ/AWS_REGION

  - model_name: webSearch
    litellm_params:
      model: anthropic/claude-opus-4-5
      api_key: os.environ/ANTHROPIC_API_KEY

litellm_settings:
  fallbacks:
    - default: [think]        # fall back to Bedrock if Ollama is down
  request_timeout: 600
  telemetry: false
```

### 4. Secrets — `secrets/api-keys.sops.yaml`

Add these keys to the encrypted secrets file:

```yaml
ANTHROPIC_API_KEY: <your-anthropic-api-key>
AWS_ACCESS_KEY_ID: <your-aws-access-key-id>
AWS_SECRET_ACCESS_KEY: <your-aws-secret-access-key>
HF_TOKEN: <your-hf-token>
LITELLM_MASTER_KEY: <generate-a-random-key>   # secures the LiteLLM proxy API
```

```bash
ai-secrets edit   # decrypt → add keys → re-encrypt
```

All keys are loaded at stack start via `source <(ai-secrets env)` and inherited by LiteLLM as environment variables — no plaintext credentials anywhere.

### 5. `ai-stack.env`

Add:

```bash
export LITELLM_PORT="4000"
```

Update `ANTHROPIC_BASE_URL` to point at LiteLLM instead of CCR when the multi profile is active — handled automatically by the profile's Procfile since Headroom reads `CCR_PORT` / `LITELLM_PORT`.

> Note: Headroom's `--anthropic-api-url` will need to point to `http://localhost:${LITELLM_PORT}` in a dedicated `launch-multi` script or via an env var override.

## Migration Trigger

Do this when **all three** are true:

- Bedrock credentials are active and tested
- Anthropic API key is provisioned
- You find yourself switching profiles manually to access different providers

Until then, the current CCR-based stack is simpler and sufficient.

## What Does Not Change

- Headroom stays as the Claude Code entry point (`http://localhost:8787`)
- `ANTHROPIC_BASE_URL=http://localhost:8787` stays unchanged for all tools
- Secret management via SOPS + age — just add new keys to the existing file
- `ai-models` for model downloads — Ollama models unchanged
- All existing profiles (`default`, `local`, `mistral`, `cloud`) remain functional
