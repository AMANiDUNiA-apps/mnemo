---
sensitivity: INTERNAL
doc_size: S
---
# Agent Memory Index

This public repo holds the **framework**: shared conventions, role definitions,
and the per-profile structure documented below.

## Profiles live in a private instance repo

The actual `profile/` tree — real soul/instructions/rules, todos, and any
infrastructure-specific content — lives in the private companion repo
**`mnemo-brain`**, not here. At runtime both repos are cloned so their
`brain-memory/agent-memory/` paths overlay into one memory layer:

```
brain-memory/agent-memory/
├── _all/        ← this repo (shared conventions)
└── profile/     ← mnemo-brain (private real content)
```

This split keeps the public framework free of personal infrastructure details
while the private instance stays out of public view.

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
