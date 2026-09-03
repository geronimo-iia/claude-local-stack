# Roadmap: Claude Max Plan + LiteLLM + Local Fallback

## Context

Personal usage analysis from headroom logs (May–July 2026, 5 active days):

| Day | Requests | Input (optimized) | Output |
|-----|----------|-------------------|--------|
| 2026-05-14 | 54 | 0.3M | 6K |
| 2026-05-15 | 40 | 0.2M | ~0 |
| 2026-07-13 | 569 | 35.6M | 106K |
| 2026-07-14 | 1,157 | 178M | 253K |
| 2026-07-23 | 1 | ~0 | ~0 |

Average per active day: **43M input tokens, 73K output tokens**.

At pay-per-token rates (Sonnet 4.6: $3/MTok input, $15/MTok output), a single heavy day costs $130–$535.
At any realistic frequency, API billing is 5–20x more expensive than a flat Max plan.

**Decision: Claude Max plan ($100/month) is the correct cost model.**

Local MLX is not a cost optimization — it is a throttle fallback and offline mode.

## Cost Comparison

| Active days/month | Anthropic API | AWS Bedrock | Claude Max |
|-------------------|---------------|-------------|------------|
| 4 | ~$520 | ~$605 | **$100** |
| 8 | ~$1,040 | ~$1,210 | **$100** |
| 15 | ~$1,950 | ~$2,270 | **$100** |

Bedrock is consistently 15–20% more expensive than direct API at the token level.
Kiro credits are IDE-specific and not portable to this stack.

**Claude Max wins at every usage level. AWS Bedrock and Kiro are not worth pursuing.**

## What Claude Max Limits Mean

Claude Max is not unlimited — it enforces rate limits that reset every few hours.
At 178M input tokens in one day (July 14), the plan likely throttled mid-session.

Mitigation:
1. Prompt caching (cache reads count less against limits, cost 10x less on API)
2. Local MLX as automatic fallback when throttled — transparent to Claude Code

## Final Architecture

```
Claude Code
  → Headroom :8787      (token compression proxy)
    → LiteLLM :4000     (routing + 429 fallback)
      → Anthropic API   (primary — Claude Max plan)
      → rapid-mlx :8000 (fallback on rate limit / offline)
```

Headroom is not a router — it compresses tokens and passes through to LiteLLM.
LiteLLM detects 429 from Anthropic and transparently retries on the local model.

## What Changes From Current Stack

| Component | Current | New |
|-----------|---------|-----|
| Primary provider | Headroom → CCR → Bedrock or local | Headroom → LiteLLM → Anthropic Max |
| Fallback | Manual profile switch | Automatic on 429 |
| Local model | Default route | Rate-limit fallback only |
| CCR | Routes by task type | Replaced by LiteLLM |
| Bedrock | Cloud profile | Removed from primary path |

## New Profile: `max`

```
config/profiles/max/
├── litellm.yaml      → config/litellm.yaml on activation
├── services.yaml     litellm + headroom + rapid-mlx
├── Procfile          litellm: ... / headroom: ... / rapid-mlx: ...
└── readme.md
```

`Procfile`:
```
rapid-mlx: ${AI_HOME}/lib/services/rapid-mlx/launch
litellm:   ${AI_HOME}/lib/services/litellm/launch
headroom:  ${AI_HOME}/lib/services/headroom/launch
```

`config/profiles/max/litellm.yaml`:
```yaml
model_list:
  - model_name: default
    litellm_params:
      model: anthropic/claude-sonnet-4-6
      api_key: os.environ/ANTHROPIC_API_KEY

  - model_name: default-fallback
    litellm_params:
      model: openai/qwen
      api_base: http://localhost:8000
      api_key: local

router_settings:
  fallbacks:
    - default: [default-fallback]
  retry_policy:
    RateLimitErrorRetries: 1
  num_retries: 2

litellm_settings:
  request_timeout: 600
  telemetry: false
```

Headroom `--anthropic-api-url` must point to `http://localhost:${LITELLM_PORT}` in the `max` profile launch script.

## Prompt Caching

**Bedrock (cloud profile): caching is broken — by design.**

Trace:
1. LiteLLM routes `eu.anthropic.claude-sonnet-4-6` through the Bedrock **Converse API**
   (cross-region inference profiles always use Converse, not the Messages API)
2. LiteLLM converts `cache_control` → Bedrock `cachePoint` blocks — transformation is correct
3. Bedrock returns `cache_creation_input_tokens=0` on all 1,157 requests (July 14 log)
   → eu-west-1 Converse API does not support prompt caching for this model/region

`proxy_savings.json` confirms: `lifetime.cache_read_tokens: 0` across 214M tokens processed.

**Max profile: caching works out of the box.**

Headroom → Anthropic direct API uses the Messages API natively.
Headroom places `cache_control` at the stable prefix boundary after compression.
Bedrock is not in the path. No Converse translation. No regional gap.

Verify after first sustained Max-profile session:

```bash
python3 -c "
import json
print(json.load(open('~/.headroom/proxy_savings.json'))['lifetime']['cache_read_tokens'])
"
```

Expected: non-zero after 2+ turns in the same session.
Cost impact: prefix reads at $0.30/MTok vs $3/MTok input (10x). Also reduces rate-limit consumption.

## Secrets Required

Add to `secrets/api-keys.sops.yaml` via `ai-secrets edit`:

```yaml
ANTHROPIC_API_KEY: <claude-max-api-key>
```

No AWS credentials needed for this profile.

## Migration Trigger

Implement when:
- `ANTHROPIC_API_KEY` provisioned and tested
- Current profile switching (default ↔ cloud) is causing friction
- Rate limiting on heavy days is blocking work

Until then, the cloud profile (Bedrock) remains functional.

## What Does Not Change

- Headroom stays as the Claude Code entry point (`http://localhost:8787`)
- `ANTHROPIC_BASE_URL=http://localhost:8787` unchanged for all tools
- Secret management via SOPS + age
- `ai-models` for local model downloads
- All existing profiles (`default`, `local`, `cloud`, `mistral`) remain functional
- rapid-mlx and Qwen3.6-35B-A3B remain the local inference backend

## Relation to Other Roadmap Docs

`litellm.md` — multi-provider routing with Ollama + Bedrock + Anthropic. Still valid if
Bedrock becomes useful later (e.g. org/team billing). The `max` profile is a simpler
subset: two providers only (Anthropic Max + local), no Ollama, no Bedrock.

`bifrost.md` — budget gateway and observability. Revisit if per-session cost tracking
becomes important. Not needed while on a flat Max plan.
