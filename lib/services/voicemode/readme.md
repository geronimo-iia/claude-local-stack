# voicemode — Voice I/O for Claude Code

Source: https://github.com/nicobailon/voice-mode

MCP server providing speech-to-text (Whisper) and text-to-speech (Kokoro) for Claude Code.

## Port

8765 (MCP over streamable HTTP)

## Install

```bash
ai-install voicemode
```

Installs `voice-mode` via uv, downloads Whisper (GPU) and Kokoro models, registers MCP in `~/.claude.json`.

## Launch

```bash
voicemode serve --transport streamable-http
```

Delegated to `supervised-launch` via the `launch` script.

## Dependencies

Requires brew packages: `ffmpeg`, `portaudio`, `cmake` (installed by `lib/setup/tooling`).
