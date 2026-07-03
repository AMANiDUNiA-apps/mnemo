---
sensitivity: PUBLIC
doc_size: M
layer: sensitivity-layer
---
# Sensitivity Layer

Cross-cutting policy for **all** layers. Every memory file carries a `sensitivity:`
frontmatter tag; this layer defines what each tag means and how it is enforced.
Guiding principle: **storage location enforces the tag** (as proven by the public↔private split).

## Tags

| Tag | Meaning | LLM Access | Logging |
|---|---|---|---|
| `PUBLIC` | Free to forward, external models OK | All | Full |
| `INTERNAL` | Local models only, no cloud LLM | Local only | Metadata |
| `SENSITIVE` | Never in LLM context, structural reference only | Never | No payload |
| `PRIVATE` | Absolutely local, no logging | Never | Nothing |

## Enforcement

- Every memory file **MUST** include `sensitivity: TAG` — files without it are rejected.
- `SENSITIVE`/`PRIVATE` payloads are stripped before any LLM call.
- `INTERNAL` content goes only to local models.
- `PUBLIC` has no restrictions.
- Placement rule: `PUBLIC` → shareable framework repo; `INTERNAL`+ → private instance / local only.

## Configuration (`config.yaml`)

```yaml
enabled: true
default_tag: "INTERNAL"
enforcement: "strict"        # blocks non-compliant content from LLM context
feature_flags:
  pii_redaction: true
  tag_enforcement: true
  log_filtering: true
```
