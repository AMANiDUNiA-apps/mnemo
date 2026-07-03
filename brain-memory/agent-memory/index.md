---
sensitivity: INTERNAL
doc_size: S
---
# Agent Memory Index

This public repo holds the **framework**: shared conventions, role definitions,
and the per-profile structure documented below.

## AgentOS: building blocks + profiles

`agent-memory` is an **AgentOS**: a kit of building blocks plus profiles that
compose them by ID. Everything is Markdown + YAML frontmatter.

| Block | Holds |
|---|---|
| `agent-runtime/` | Runtime definitions (claude-code, hermes, …) |
| `agent-llms/` | Model/provider definitions with roles & `best_for` |
| `agent-skills/` | Skills shared or distilled (see skill-forge loop) |
| `agent-mcps/` | MCP server definitions |
| `agent-clis/` | CLI tool definitions |
| `agent-profiles/<group>/<name>/` | Profiles composing blocks by ID |
| `_all/` | Shared conventions, build guide, validator, fail captures |

## Profiles live in a private instance repo

Real profile content (soul/instructions/rules, todos, plans) lives in the
private companion repo **`mnemo-brain-memory-intern`**, not here. At runtime
the public skeleton and the private content overlay into one live tree:

```
brain-memory/agent-memory/
├── _all/              ← this repo (shared conventions, validator)
├── agent-<block>/     ← skeleton here, real definitions private
└── agent-profiles/    ← real profiles private
```

This split keeps the public framework free of personal infrastructure details
while the private instance stays out of public view. See
`docs/overlay-architecture.md` for the full overlay contract.

## Shared Content

| Path | Purpose |
|---|---|
| `_all/base-conventions.md` | Universal file format, naming, wikilink conventions |
| `_all/sensitivity-handling.md` | Sensitivity tag enforcement rules |
| `_all/git-workflow.md` | Branch and merge conventions |
| `agent-skills/` | Skills shared across profiles (block, composed by ID) |

## Role Conventions

| Role | Folder | Responsibility |
|---|---|---|
| Manager | `<category>/manager/` | Dispatcher — routes, delegates, synthesizes. No direct execution. |
| Reviewer | `<category>/reviewer/` | Quality gate — approves output before it leaves the category. |
| Default | `<category>/default/` | Generalist catch-all executor for the category. |
| Specific | `<category>/<name>/` | Specialized executor for a defined domain. |

## Per-Profile Structure

Every profile folder:
```
agent-profiles/<group>/<name>/
├── CLAUDE.md          ← YAML frontmatter composes blocks by ID + policy
├── core/
│   ├── soul.md        ← what the agent IS
│   ├── instructions.md
│   ├── rules.md       ← what it MAY / DOES
│   └── log.md
├── todos/             ← open tasks (one .md per todo, YAML frontmatter)
├── ideas/             ← improvement/research ideas backlog
└── plans/             ← active operational plans (living documents)
```

Block IDs referenced in `CLAUDE.md` frontmatter **must exist** in the block
registry — missing blocks go into a `needs-blocks:` field instead of being
invented. A validator (`_all/validate-profiles.py` in the instance) gates
this: exit 0 = clean.

See `docs/superpowers/specs/2026-06-30-agent-memory-schema-design.md` for the full spec.
