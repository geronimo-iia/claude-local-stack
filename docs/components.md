# Components

Components live under `lib/` in two categories:

| Category | Path            | Has `launch` | Managed by overmind |
| -------- | --------------- | :----------: | :-----------------: |
| Services | `lib/services/` |      ✓       |          ✓          |
| Plugins  | `lib/plugins/`  |      ✗       |          ✗          |

## Directory structure

```
lib/services/headroom/
├── install          # idempotent install script (required)
├── launch           # start the daemon (services only)
├── priority         # install order integer (optional, default: 50)
└── readme.md        # description (optional)
```

## Services

| Name      | Purpose                                    | Port      |
| --------- | ------------------------------------------ | --------- |
| rapid-mlx | Local MLX inference                        | 8000-8002 |
| ollama    | Local Ollama inference                     | 11434     |
| litellm   | Model routing proxy                        | 4000      |
| headroom  | Token compression proxy                    | 8787      |
| voicemode | Voice I/O (STT + TTS)                     | 8765      |
| llm-wiki  | Git-backed wiki engine (binary, no daemon) | —         |

## Plugins

| Name                | Purpose                                        |
| ------------------- | ---------------------------------------------- |
| context-mode        | Context management for Claude                  |
| superpowers         | Extended Claude capabilities                   |
| caveman             | Output token compression                       |
| rtk                 | Prompt toolkit                                 |
| drawio              | Diagram integration                            |
| atlassian           | Jira/Confluence integration                    |
| llm-wiki-skills     | Wiki skills — ingest, research, crystallize, graph (MCP via llm-wiki) |

## rapid-mlx configuration

Defined in `config/rapid-mlx.yaml` (copied from active profile):

```yaml
instances:
  - role: default
    port: 8000
    model: mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B
    embedding_model: mlx-community/Qwen3-Embedding-0.6B-4bit-DWQ
    max_tokens: 32768
    tool_call_parser: qwen3_coder_xml
    no_thinking: true
    suffix_decoding: true
    features: [tool-calling, continuous-batching]
```

| Field             | Required | Description                                                        |
| ----------------- | :------: | ------------------------------------------------------------------ |
| role              |    ✓     | Instance name (matches Procfile entry)                             |
| port              |    ✓     | Listen port                                                        |
| model             |    ✓     | HuggingFace repo ID                                                |
| embedding_model   |          | HuggingFace repo ID for embeddings                                 |
| max_tokens        |          | Max output tokens (default: 32768)                                 |
| tool_call_parser  |          | Parser for tool calls: `auto`, `qwen3_coder`, `qwen3_xml`, `hermes`, etc. |
| reasoning_parser  |          | Reasoning extraction: `qwen3`, `deepseek_r1`, `gemma4`, etc.       |
| paged_cache       |          | Enable paged KV cache (`true`/`false`)                             |
| no_thinking       |          | Disable thinking/reasoning output (`true`/`false`)                 |
| mtp               |          | Enable multi-token prediction (`true`/`false`)                     |
| suffix_decoding   |          | Enable suffix decoding (`true`/`false`)                            |
| temperature       |          | Default sampling temperature                                       |
| top_p             |          | Default top-p sampling                                             |
| trust_remote_code |          | Allow remote code execution for model loading                      |
| features          |          | Feature flags (see below)                                          |

### Features

| Feature               | CLI flag added              |
| --------------------- | --------------------------- |
| `tool-calling`        | `--enable-auto-tool-choice` |
| `continuous-batching` | `--continuous-batching`     |
| `reasoning`           | `--reasoning-parser qwen3`  |

## Adding a component

1. Create directory under `lib/services/` or `lib/plugins/`
2. Add `install` script (idempotent, sourced by ai-install)
3. For services: add `launch` script + Procfile entry in relevant profiles
4. Optional: `priority`, `readme.md`
