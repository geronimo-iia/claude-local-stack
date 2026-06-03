# Cloud Profile

Minimal profile that uses AWS Bedrock. Only runs Headroom locally for memory augmentation.

## Architecture Flow

```
Claude Code → Headroom (:8787) → AWS Bedrock
```

## Services

| Service | Port | Role |
|---------|------|------|
| Headroom | 8787 | Memory-augmented proxy between Claude Code and Bedrock |

No local inference, no CCR routing — just the memory layer in front of the cloud API.

## Prerequisites

`AWS_PROFILE` and `AWS_REGION` must be set in `config/ai-stack.env`. You must be authenticated before starting the stack:

```sh
aws sso login --profile $AWS_PROFILE
```

## When to Use

- Tasks requiring Claude's full capability (Opus/Sonnet) via Bedrock
- Long-context work beyond local model limits
- When you want persistent memory but don't need local inference
- Online environments with AWS credentials available
