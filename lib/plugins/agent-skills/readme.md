# agent-skills

Source: https://github.com/geronimo-iia/agent-skills

Claude Code plugin with skills for research, PDF extraction, knowledge-base
management, and writing quality.

## CLI dependencies

| Tool | Install | Purpose |
|---|---|---|
| `xberg` | `brew install xberg-io/tap/xberg` | Machine-readable PDF extraction (pdf-parse skill) |
| `poppler` | `brew install poppler` | `pdftotext` fallback for PDF extraction |
| `llm` | `uv tool install llm` | LLM calls from pipeline (40+ providers, Ollama) |
| `llm-ollama` | `llm install llm-ollama` | Local model support via Ollama |
| `code2prompt` | `cargo install code2prompt` | Bundle codebase as LLM prompt (oracle skill) |
| `summarize` | `brew install steipete/tap/summarize` | Optional — all-in-one URL/PDF/audio summarizer |

`marker-pdf`, `markitdown`, and `fabric` are used via `uvx` — no install needed.

## Skills

| Skill | Invocation | Description |
|---|---|---|
| `anti-slop` | Auto | Strip AI slop from written artifacts |
| `kb-conventions` | Auto | KB layout, confidence markers, source schema |
| `pdf-parse` | `/geronimo-skills:pdf-parse` | Dual-path PDF extraction (xberg / marker-pdf) |
| `research-paper` | `/geronimo-skills:research-paper` | Single paper → KB topic |
| `research-extraction` | `/geronimo-skills:research-extraction` | Multi-source extraction with reviewer gating |
| `coding-agent` | `/geronimo-skills:coding-agent` | Background coding agent orchestration |
| `oracle` | `/geronimo-skills:oracle` | Second-model review / cross-validation |
| `summarize` | `/geronimo-skills:summarize` | Summarize URLs, PDFs, audio, YouTube |

## Optional install

`summarize` CLI is gated behind `INSTALL_SUMMARIZE=true`:
```bash
INSTALL_SUMMARIZE=true ai-stack plugin install agent-skills

Plugin installs as `geronimo-skills@geronimo-agent-skills`.
```
