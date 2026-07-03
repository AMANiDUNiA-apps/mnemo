---
sensitivity: PUBLIC
doc_size: S
layer: root
---
# brain-memory — Live Instance

The 8-layer memory system for the mnemo agent ecosystem. Each layer has a distinct
purpose, ownership, retention, and default sensitivity. Agents load only the subset
they need via namespaces, tags, and doc-size tiers.

## Layers

| Layer | Purpose | Default Sensitivity |
|---|---|---|
| [[agent-memory/index]] | Agent definitions: profiles, skills, runtimes, MCPs, master plan | INTERNAL |
| [[knowledge-memory/index]] | External knowledge: repos (Gortex), wiki, RAG indices | INTERNAL |
| [[project-memory/index]] | Per-project goals, stack, ADRs, todos + master plan | INTERNAL |
| [[session-memory/index]] | Per-session raw export + tiered summaries + learnings | INTERNAL |
| [[user-memory/index]] | User profile(s) + preferences, tiered xS–XL | INTERNAL |
| [[longterm-memory/index]] | Promoted cross-session insights & patterns | INTERNAL |
| [[sensitivity-layer/index]] | Cross-cutting: sensitivity tags + enforcement policy | — |
| [[telemetry/index]] | Token/cost tracking, traces (Langfuse) | INTERNAL |

## Conventions

- **Doc-size tiering** — substantial docs ship tiers `-xs … -xl`; agents load the
  smallest sufficient context.
- **Sensitivity** — every file carries a `sensitivity:` frontmatter tag; the
  **storage location enforces it** (PUBLIC → shareable; INTERNAL+ → private/local
  only). See [[sensitivity-layer/index]].
- **Wikilinks** — cross-reference other memory with `[[layer/path]]`.
- **Public/private split** — a shareable framework skeleton + a private content
  instance overlay into this tree. *(Git wiring: overlay v0.2 — see `docs/overlay-architecture.md` + `config.yaml`.)*

> This tree is the **live, assembled** view agents read. Framework spec:
> `github.com/amaniagent/mnemo`.
