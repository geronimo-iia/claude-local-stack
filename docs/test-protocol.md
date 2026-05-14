# Activate profile (copies all configs)
ai-stack profile default

# Disable everything first
ai-stack disable rapid-mlx-default headroom ccr

# Test rapid-mlx alone
ai-stack enable rapid-mlx-default
ai-stack start
# verify: curl http://localhost:8000/v1/models
ai-stack stop


# Add ccr
ai-stack enable ccr
ai-stack start
# verify: curl http://localhost:3456/v1/models
ai-stack stop



curl -s -X POST -H "x-api-key: local" -H "Content-Type: application/json" -H "anthropic-version: 2023-06-01" http://localhost:3456/v1/messages -d '{"model":"claude-sonnet-4-20250514","messages":[{"role":"user","content":"hi"}],"max_tokens":10}'


# Add headroom
ai-stack enable headroom
ai-stack start
# verify: curl http://localhost:8787/v1/models
ai-stack stop


curl -s -X POST -H "x-api-key: local" -H "Content-Type: application/json" -H "anthropic-version: 2023-06-01" http://localhost:8787/v1/messages -d '{"model":"claude-sonnet-4-20250514","messages":[{"role":"user","content":"hi"}],"max_tokens":8192}'

purpose me a readme for the project under /Users/geronimo/dev/labs/ai/ai-stack 
