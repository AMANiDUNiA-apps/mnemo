---
sensitivity: PUBLIC
doc_size: S
layer: agent-memory
---
# Agent Memory Index

Everything that **defines an agent**: profiles (persona, rules, skills), the runtimes
they run on, the MCP servers they share, reusable skills, and the overarching plan.

## Structure

| Path | Purpose |
|---|---|
| `agent-master-plan/` | Overarching plan for the agent system (roadmaps, specs) |
| `agent-profiles/` | Profile definitions, grouped by domain (see below) |
| `agent-runtime/` | Runtime-specific config/adapters: `claude-code/`, `hermes-agent/`, `open-code/` |
| `agent-llms/` | Model/provider definitions (roles, cost, `best_for`) |
| `agent-skills/` | Reusable skills: `code-skills/` (metal/swift/web), `design-skills/`, `planning-skills/` |
| `agent-mcps/` | MCP server configs shared across profiles |
| `agent-clis/` | CLI tool definitions shared across profiles |
| `_all/` | Shared conventions (base format, naming, sensitivity handling, wikilinks), build guide, validator |

## Profile Groups (`agent-profiles/<group>/`)

`article-press-agents` · `assistent-agents` · `design-agents` ·
`memory-manager-agents` · `researcher-agents` · `swift-agents` ·
`system-agents` · `tool-agents`

## Role Convention (within a group)

| Role | Folder | Responsibility |
|---|---|---|
| Manager | `<group>-manager/` | Dispatcher — routes/delegates/synthesizes; no direct execution |
| Optimizer | `<group>-optimizer/` | Improves the group's profiles, skills, prompts |
| Reviewer | `<group>-reviewer/` | Quality gate before output leaves the group |
| Specific | `<group>/<name>/` | Specialized executor (e.g. `swift-agents/swift-vapor/`) |

## Per-Profile Structure (target)

```
<profile>/
├── CLAUDE.md          ← lean entry: frontmatter composes blocks by id + policy
├── core/              ← the agent's definition
│   ├── soul.md        (is) · instructions.md (does)
│   ├── rules.md       (may / may-not) · log.md
├── todos/  ideas/  plans/
```

Skills/MCPs/CLIs are **not** copied per profile — they live in their blocks
(`agent-skills/`, `agent-mcps/`, `agent-clis/`) and are referenced by `id` in the
profile's frontmatter. Skeleton is shareable; real `soul.md`/`rules.md`/todos are private.

Block ids referenced in `CLAUDE.md` frontmatter **must exist** in the id registry —
missing blocks go into a `needs-blocks:` field instead of being invented. A validator
(`_all/validate-profiles.py`) gates this: exit 0 = clean.

> Public/private split: the skeleton and these conventions are the public framework;
> real profile content overlays from the private instance repo.
> See `docs/overlay-architecture.md` for the overlay contract.
