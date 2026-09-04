{
  "$schema": "https://www.getbifrost.ai/schema",
  "providers": {
    "bedrock": {
      "keys": [
        {
          "name": "bedrock-key",
          "value": "${AWS_ACCESS_KEY_ID}",
          "models": ["*"],
          "weight": 1.0,
          "aliases": {
            "claude-haiku-3-5-20241022": "eu.anthropic.claude-haiku-4-5-20251001-v1:0",
            "claude-haiku-4-5-20251001": "eu.anthropic.claude-haiku-4-5-20251001-v1:0",
            "claude-sonnet-4-5": "eu.anthropic.claude-sonnet-5",
            "claude-sonnet-4-6": "eu.anthropic.claude-sonnet-5",
            "claude-sonnet-5": "eu.anthropic.claude-sonnet-5",
            "claude-opus-4-5": "eu.anthropic.claude-opus-5",
            "claude-opus-5": "eu.anthropic.claude-opus-5",
            "*": "eu.anthropic.claude-sonnet-5"
          }
        }
      ],
      "network_config": {
        "aws_region": "${AWS_REGION}"
      }
    }
  },
  "config_store": {
    "enabled": false
  }
}
