# rapid-mlx

Local LLM inference server (MLX-accelerated), configured via `config/rapid-mlx.yaml`.

## Configuration

Each entry in `instances` defines a server role:

```yaml
instances:
  - role: default
    port: 8000
    model: arthurcollet/Qwen3.6-35B-A3B-mlx-mxfp8
    embedding_model: mlx-community/bge-m3-mlx-4bit
    context_length: 32768
    max_tokens: 8192
    tool_call_parser: qwen3
    features: [tool-calling, continuous-batching]
```

### Required fields

| Field | Description |
|-------|-------------|
| `role` | Instance name (`default`, `background`, `think`, …) |
| `port` | Listen port |
| `model` | HuggingFace repo ID |

### Optional fields

| Field | Description |
|-------|-------------|
| `embedding_model` | HuggingFace repo ID for embeddings |
| `context_length` | Max context window (model max if omitted) |
| `max_tokens` | Max output tokens |
| `temperature` | Default sampling temperature |
| `top_p` | Default top-p sampling |
| `trust_remote_code` | Allow remote code execution for model loading |
| `tool_call_parser` | Parser for tool calls (e.g. `qwen3`) |
| `features` | List of feature flags (see below) |

### Features

| Feature | CLI flag added |
|---------|---------------|
| `tool-calling` | `--enable-auto-tool-choice` |
| `continuous-batching` | `--continuous-batching` |
| `reasoning` | `--reasoning-parser qwen3` |

## Launch script

`lib/services/rapid-mlx/launch` reads the config and builds the CLI command dynamically:

1. Takes a role argument (defaults to `default`)
2. Extracts fields for that role from `config/rapid-mlx.yaml`
3. Builds the `rapid-mlx serve` command with only the flags that have values
4. Appends feature flags
5. `exec` the final command

### Running a specific role

```bash
lib/services/rapid-mlx/launch background
```

### Multiple instances

To run several roles simultaneously, add separate Procfile entries:

```procfile
rapid-mlx: lib/services/rapid-mlx/launch default
rapid-mlx-bg: lib/services/rapid-mlx/launch background
rapid-mlx-think: lib/services/rapid-mlx/launch think
```
