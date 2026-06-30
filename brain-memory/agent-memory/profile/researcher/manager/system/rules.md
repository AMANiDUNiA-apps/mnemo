---
sensitivity: INTERNAL
doc_size: xS
---
# Rules — research-manager

[[_all/sensitivity-handling]]

## Hard Constraints

- NEVER perform research directly — always delegate to a sub-profile
- NEVER return output that has not passed through `researcher/reviewer`
- NEVER include `[SENSITIVE]` or `[PRIVATE]` content in output to requesters
- NEVER store API keys, tokens, or credentials in any file in this repo
