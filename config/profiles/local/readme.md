# Local Profile

Multi-model profile. Three tiered inference instances — tasks routed by complexity. Fully local, no cloud dependencies.

## Architecture Flow

```
Claude Code → Headroom (:8787) → CCR (:3456) → rapid-mlx-default  (:8000) → Qwen3.6-35B-A3B  [default / longContext]
                                              → rapid-mlx-background(:8001) → Qwen3.6-27B      [background]
                                              → rapid-mlx-think     (:8002) → Qwen3-235B-A22B  [think] (disabled by default)
```

## Services

| Service | Port | Role |
|---------|------|------|
| rapid-mlx-default | 8000 | Default + longContext tasks (35B MoE) |
| rapid-mlx-background | 8001 | Background / agentic subtasks (27B) |
| rapid-mlx-think | 8002 | Deep reasoning (235B MoE) — **disabled by default** |
| CCR | 3456 | Multi-route dispatcher, status line, token tracking |
| Headroom | 8787 | Memory-augmented proxy between Claude Code and CCR |

## Models

| Role | Model | Active params | Max tokens |
|------|-------|--------------|------------|
| default | arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8 | 3B | 8192 |
| background | arthurcollet/Qwen3.6-27B-mlx-mxfp8 | 27B | 4096 |
| think | mlx-community/Qwen3-235B-A22B-4bit | 22B | 16384 |

## Routing

CCR dispatches each request to the appropriate tier:

| Route | Destination | Use case |
|-------|-------------|----------|
| `default` | rapid-mlx-default (35B) | Most coding tasks |
| `background` | rapid-mlx-background (27B) | Agentic subtasks, summaries |
| `think` | rapid-mlx-think (235B) | Complex reasoning, architecture |
| `longContext` | rapid-mlx-default (35B) | Contexts > 60k tokens |

## Enabling the Think Instance

The `rapid-mlx-think` service is commented out in `Procfile` because Qwen3-235B requires significant unified memory.

**Minimum requirement: 128GB unified memory** (M2/M3/M4 Ultra or Max with 128GB+).

To enable:

```sh
ai-stack enable rapid-mlx-think
```

Then download the model if not already cached:

```sh
ai-models pull mlx-community/Qwen3-235B-A22B-4bit
```

## When to Use

- Multi-task sessions with concurrent background agents
- When you want lighter model handling routine subtasks to preserve main model capacity
- Complex reasoning tasks that benefit from the 235B think tier (with sufficient RAM)
