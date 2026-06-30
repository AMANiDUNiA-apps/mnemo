---
sensitivity: PUBLIC
doc_size: S
---
# Sensitivity Handling

## Tags

| Tag | LLM Access | Logging | Meaning |
|---|---|---|---|
| `[PUBLIC]` | All models | Full | Safe to forward, external models OK |
| `[INTERNAL]` | Local models only | Metadata only | No cloud LLMs |
| `[SENSITIVE]` | Never | No payload | Structural reference only |
| `[PRIVATE]` | Never | Nothing | Absolutely local, no logging |

## Enforcement Rules

- Check `sensitivity` frontmatter BEFORE including any file in LLM context
- `INTERNAL` and above: never send to cloud APIs (Claude, OpenAI, Gemini, etc.)
- Files without a sensitivity tag: treat as `INTERNAL`
- When in doubt: escalate to the next more restrictive level

## Secrets

- API keys, passwords, tokens, credentials: NEVER in the mnemo repo
- Use a professional secrets manager (e.g. Bitwarden) — mandatory in Germany (GDPR)
- Runtime config containing secrets stays local per machine, not version-controlled
- Use `config.yaml.example` in the repo as the template; actual values live locally
