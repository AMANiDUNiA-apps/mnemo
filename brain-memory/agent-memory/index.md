---
sensitivity: INTERNAL
doc_size: S
---
# Agent Memory Index

Overview of all profiles in `brain-memory/agent-memory/profile/`.

## Profile Categories

| Category | Profiles | Status |
|---|---|---|
| `researcher/` | 🟢 manager, reviewer, default · ⚪ food, llm/{google,nvidia,overall,owl-alpha} | 🟢 = fully scaffolded · ⚪ = bare dir |
| `assistent/` | 🟡 manager, reviewer · ⚪ cleaner, tagger | 🟡 = stubbed · ⚪ = bare dir |
| `developer/` | 🟡 manager, reviewer · ⚪ swift-developer, system-developer | 🟡 = stubbed · ⚪ = bare dir |
| `designer/` | 🟡 manager, reviewer | 🟡 = stubbed |
| `memory-manager/` | 🟡 manager, reviewer · ⚪ brain-memory-manager, knowledge-memory-manager | 🟡 = stubbed · ⚪ = bare dir |
| `tutor/` | 🟡 manager, reviewer · ⚪ swift-tutor | 🟡 = stubbed · ⚪ = bare dir |

> **Legend:** 🟢 fully scaffolded (soul/instructions/rules/etc.) · 🟡 stub only (TODO instructions/rules) · ⚪ bare dir (no scaffold yet)

## Shared Content

| Path | Purpose |
|---|---|
| `_all/base-conventions.md` | Universal file format, naming, wikilink conventions |
| `_all/sensitivity-handling.md` | Sensitivity tag enforcement rules |
| `_all/git-workflow.md` | Branch and merge conventions |
| `_all/skills/` | Skills shared across profiles |

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
<profile>/
├── CLAUDE.md          ← lean entry point with [[wikilink]] references
├── projects/          ← filtered context from project-memory
├── todos/             ← open tasks (one .md per todo, YAML frontmatter)
├── ideas/             ← improvement/research ideas backlog
├── plans/             ← active operational plans (living documents)
└── system/
    ├── soul.md
    ├── instructions.md
    ├── rules.md
    ├── skills/
    ├── index.md
    └── log.md
```

See `docs/superpowers/specs/2026-06-30-agent-memory-schema-design.md` for the full spec.
