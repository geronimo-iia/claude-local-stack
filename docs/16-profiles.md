# Profiles

> Supersedes: `docs/routing-profiles.md` (OBSOLETE)

## Problem

The current `ai-stack profile` command conflates CCR preset management with service toggling. It:
- Depends on `ccr preset install/list` internals
- Derives which services to run from the CCR config (parsing `jq` on provider names)
- Cannot manage non-routing services (headroom config, ports, flags)

A "profile" should be a complete, self-contained stack configuration.

## Design

A profile is a directory containing:

```
config/profiles/
├── default/
│   ├── ccr.json         # CCR routing config (copied to ~/.claude-code-router/config.json)
│   ├── rapid-mlx.yaml   # rapid-mlx instance definitions (copied to config/rapid-mlx.yaml)
│   └── Procfile         # Full Procfile for overmind (replaces config/Procfile)
├── local/
│   ├── ccr.json
│   ├── rapid-mlx.yaml
│   └── Procfile
├── hybrid/
│   ├── ccr.json
│   ├── rapid-mlx.yaml
│   └── Procfile
└── cloud/
    ├── ccr.json
    └── Procfile          # no rapid-mlx.yaml (no local models)
```

### Why a full Procfile per profile

- Each profile may need different services, different flags, different ports
- No toggle logic — the Procfile IS the truth for what runs
- Adding/removing a service from a profile is a one-line edit in the right file
- Headroom, CCR, rapid-mlx instances are all treated uniformly

### Why `rapid-mlx.yaml` per profile

- Different profiles need different models, context lengths, and instances
- The Procfile says *what* runs, `rapid-mlx.yaml` says *how* it runs — they're coupled
- Cloud profile needs no yaml at all (no local models)
- Avoids running unused instance definitions

### What `ai-stack profile <name>` does

1. Validate profile directory exists
2. Copy `ccr.json` → `~/.claude-code-router/config.json`
3. Copy `rapid-mlx.yaml` → `config/rapid-mlx.yaml` (if present)
4. Copy `Procfile` → `config/Procfile` (the active Procfile)
5. Record active profile name (symlink or file)
6. Restart stack if running

### Active profile tracking

```
config/.active-profile    # contains profile name, e.g. "hybrid"
```

### Example Procfiles

**local/Procfile:**
```procfile
rapid-mlx-default: ${AI_HOME}/lib/services/rapid-mlx/launch default
rapid-mlx-background: ${AI_HOME}/lib/services/rapid-mlx/launch background
rapid-mlx-think: ${AI_HOME}/lib/services/rapid-mlx/launch think
headroom: ${AI_HOME}/lib/services/headroom/launch
ccr: ${AI_HOME}/lib/services/claude-code-router/launch
```

**cloud/Procfile:**
```procfile
ccr: ${AI_HOME}/lib/services/claude-code-router/launch
```

**hybrid/Procfile:**
```procfile
rapid-mlx-default: ${AI_HOME}/lib/services/rapid-mlx/launch default
rapid-mlx-background: ${AI_HOME}/lib/services/rapid-mlx/launch background
headroom: ${AI_HOME}/lib/services/headroom/launch
ccr: ${AI_HOME}/lib/services/claude-code-router/launch
```

## Impact on `enable`/`disable`

`enable`/`disable` still work — they comment/uncomment lines in the active Procfile. This allows temporary overrides without switching profile. But switching profile resets the Procfile.

## Impact on `ccr` dependency

- `ccr` CLI is no longer needed for profile switching
- `ccr` is still needed at runtime (the service itself)
- The `ccr` command check moves out of the `profile` subcommand

## Migration

1. Move existing preset configs from `lib/services/claude-code-router/preset/*/config.json` → `config/profiles/*/ccr.json`
2. Create `rapid-mlx.yaml` per profile (subset of current `config/rapid-mlx.yaml`)
3. Create a `Procfile` per profile based on the routing matrix
4. Remove `lib/services/claude-code-router/preset-manage`
5. Update `ai-stack profile` implementation
6. Mark `docs/routing-profiles.md` as obsolete
