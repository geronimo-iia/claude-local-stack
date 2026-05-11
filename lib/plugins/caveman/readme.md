# Caveman — Output Token Compression

Source: https://github.com/JuliusBrussee/caveman

Claude Code plugin that reduces output tokens ~75% by making the agent respond concisely.
Full technical accuracy preserved — just fewer words.

## Trigger

Type `/caveman` in a session to activate. Say "normal mode" to deactivate.

## Modes

| Mode | Description |
|------|-------------|
| `lite` | Drop filler words |
| `full` | Default caveman (recommended) |
| `ultra` | Telegraphic |
| `wenyan` | Classical Chinese (shortest) |

## Commands

- `/caveman` — activate caveman mode
- `/caveman-stats` — show lifetime token savings
- `/caveman lite` / `full` / `ultra` / `wenyan` — switch mode

## Savings

~75% output token reduction. ~3x speed increase on generation.
