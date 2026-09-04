{
  "$schema": "https://www.getbifrost.ai/schema",
  "providers": {
    "anthropic": {
      "keys": [
        {
          "name": "anthropic-key",
          "value": "${ANTHROPIC_API_KEY}",
          "models": ["*"],
          "weight": 1.0,
          "aliases": {
            "claude-opus-5": "claude-sonnet-5",
            "claude-opus-4-5": "claude-sonnet-5",
            "claude-sonnet-5": "claude-sonnet-5",
            "claude-sonnet-4-6": "claude-sonnet-4-6",
            "claude-sonnet-4-5": "claude-sonnet-4-5",
            "claude-haiku-4-5-20251001": "claude-haiku-4-5-20251001",
            "claude-haiku-3-5-20241022": "claude-haiku-3-5-20241022",
            "*": "claude-sonnet-5"
          }
        }
      ]
    }
  },
  "config_store": {
    "enabled": false
  }
}
