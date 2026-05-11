# Installation

## Usage

```bash
ai-stack-install [target...]
ai-stack-install --list
ai-stack-install --help
```

| Command | What it does |
|---------|-------------|
| `ai-stack-install` | Install everything (setup → services → plugins) |
| `ai-stack-install setup` | Bootstrap only (prerequisites, runtimes, tooling, claude-code) |
| `ai-stack-install services` | All services |
| `ai-stack-install plugins` | All plugins |
| `ai-stack-install headroom rtk` | Cherry-pick by name (auto-detected from any category) |
| `ai-stack-install --list` | List available services and plugins with their priority |
| `ai-stack-install --help` | Show usage help |

## Install sequence

When running a full install (`all`), the order is:

1. **setup** — `prerequisites` → `runtimes` → `tooling` → `setup/*/install` (claude-code)
2. **services** — sorted by priority
3. **plugins** — sorted by priority

This ensures system deps and runtimes exist before anything else runs.

## Priority

Within `services/` and `plugins/`, install order is controlled by an optional `priority` file:

```bash
echo "10" > lib/services/headroom/priority
echo "20" > lib/services/claude-code-router/priority
```

- Lower number = installed first
- Default is `50` when no file is present
- Components with the same priority are sorted alphabetically

## Adding a new component

1. Create a directory under the appropriate category (see [repository layout](repository-layout.md)):
   - `lib/services/` — if it has a `launch` script (long-running daemon)
   - `lib/plugins/` — if it's install-only (no daemon)
   - `lib/setup/` — if it's a core prerequisite
2. Add an `install` script (and optionally `remove`)
3. Optionally add a `priority` file if ordering matters

The installer discovers components automatically — no hardcoded lists to maintain.
