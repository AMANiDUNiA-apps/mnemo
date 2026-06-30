# agent-memory Layer Schema — Design Spec

> **Status:** Approved for implementation
> **Date:** 2026-06-30
> **Sub-Project:** A (of A → E/C → B → D)
> **Canonical Spec:** `brain-memory-manager-spec.md` takes precedence on contradictions

---

## 1. Scope

This spec defines the folder schema, naming conventions, file inventory, and runtime boundaries for the `brain-memory/agent-memory/` layer. It covers:

- Per-profile folder structure (projects, todos, ideas, plans, system)
- Category/profile hierarchy including Manager + Reviewer pattern
- Tag system for avoiding boilerplate across profiles
- CLAUDE.md convention per profile
- Runtime-agnostic design & secrets boundary
- Optimization insight flow (no dedicated folder)

**Not in scope here (deferred sub-projects):**
- Runtime adapters for Hermes / OpenCode — Sub-project C (Orchestration)
- knowledge-memory layer detail — Sub-project B
- Cleaner → Tagger → Router pipeline / router logic — Sub-project D
- Multi-LLM study repo — Sub-project E

---

## 2. Profile Hierarchy

### 2.1 Directory Structure

```
brain-memory/agent-memory/
├── _all/                          ← shared content (applies to ALL profiles)
│   ├── base-conventions.md
│   ├── sensitivity-handling.md
│   └── skills/                    ← skills shared across profiles
│
├── index.md                       ← central navigation across all profiles
│
└── profile/
    ├── <category>/
    │   ├── manager/               ← dispatcher / orchestrator for this category
    │   ├── reviewer/              ← quality gate before output is routed onward
    │   ├── default/               ← generalist catch-all executor (optional per category)
    │   └── <specific-profile>/    ← specialized executor
    │       └── [sub-category]/    ← optional nesting for sub-specializations
    │           └── <specific>/
```

### 2.2 Role Definitions (per category)

| Role | Folder | Responsibility |
|---|---|---|
| **Manager** | `<category>/manager/` | Single entry point for the category. Receives requests, decides which sub-profile handles it, delegates via `delegate_task`, aggregates results. Does NOT execute work itself. |
| **Reviewer** | `<category>/reviewer/` | Quality gate. Checks output (from any sub-profile) for sources, consistency, sensitivity-tag compliance before routing onward (e.g. to knowledge-memory). |
| **Default** | `<category>/default/` | Generalist catch-all executor. Handles work directly when no specialized sub-profile fits. No routing responsibility. Optional — omit for categories where a generic fallback makes no sense. |
| **Specific** | `<category>/<name>/` | Specialized executor for a defined domain. |

### 2.3 Current Profile Inventory

```
profile/
├── assistent/
│   ├── manager/           ← NEW (to be created)
│   ├── reviewer/          ← NEW
│   ├── cleaner/           ← exists
│   └── tagger/            ← exists
│
├── designer/
│   ├── manager/           ← NEW
│   ├── reviewer/          ← NEW
│   └── default/           ← NEW (or named per specific design role later)
│
├── developer/
│   ├── manager/           ← NEW
│   ├── reviewer/          ← NEW
│   ├── swift-developer/   ← exists
│   └── system-developer/  ← exists
│
├── memory-manager/
│   ├── manager/           ← NEW (orchestrates memory-manager profiles)
│   ├── reviewer/          ← NEW
│   ├── brain-memory-manager/    ← exists
│   └── knowledge-memory-manager/ ← exists
│
├── researcher/
│   ├── manager/           ← NEW (first to be fully implemented, see §6)
│   ├── reviewer/          ← NEW
│   ├── default/           ← exists
│   ├── food/              ← exists
│   └── llm/
│       ├── google/        ← exists
│       ├── nvidia/        ← exists
│       ├── overall/       ← exists (cross-LLM synthesis)
│       └── owl-alpha/     ← exists
│
└── tutor/
    ├── manager/           ← NEW
    ├── reviewer/          ← NEW
    └── swift-tutor/       ← exists
```

---

## 3. Per-Profile Folder Schema

Every profile folder follows this structure:

```
profile/<category>/<profile-name>/
├── CLAUDE.md              ← lean entry point; references other files via [[wikilinks]]
├── projects/              ← project-specific context (filtered from project-memory)
│   └── <ProjectName>/
│       ├── summary-xs.md  ← doc-size tiered summaries (xs/s/m/l/xl per spec)
│       └── context.md     ← what THIS profile needs to know about this project
├── todos/                 ← open tasks (one .md per todo, YAML frontmatter)
│   └── <YYYY-MM-DD>-<slug>.md
├── ideas/                 ← backlog of improvement/research ideas for this profile
│   └── <YYYY-MM-DD>-<slug>.md
├── plans/                 ← active operational plans (living documents, updated as work progresses)
│   └── <YYYY-MM-DD>-<slug>.md
└── system/
    ├── soul.md            ← persona / identity
    ├── instructions.md    ← behavior rules, conventions, how this profile works
    ├── rules.md           ← hard constraints (NEVER do X)
    ├── skills/            ← skill definitions specific to this profile
    ├── index.md           ← navigation overview for this system/ folder
    └── log.md             ← running changelog / activity log
```

### 3.1 projects/ vs plans/ Distinction

| Folder | Content | Source |
|---|---|---|
| `projects/<Name>/` | *What this profile knows* about project X — context, summaries, conventions relevant to this profile. Read-heavy. | Filtered/cached from `project-memory/<Name>/` |
| `plans/` | *What this profile is currently doing* — active implementation plans, updated as work progresses. Living documents. Write-heavy. | Created here, not derived from project-memory |

### 3.2 todos/ Format

Each todo is a standalone Markdown file:

```yaml
---
title: "Research how Hermes handles Bitwarden secrets"
status: open          # open | in_progress | done | blocked
priority: high        # high | medium | low
project: mnemo
created: 2026-06-30
tags: [secrets, bitwarden, hermes, research]
---

[Todo description here]
```

### 3.3 ideas/ and plans/ Format

Same frontmatter pattern as todos/ (title, status, created, tags). Plans additionally track `phase:` and `last_updated:`.

---

## 4. system/ File Inventory

| File | Purpose | Shareable in Repo |
|---|---|---|
| `soul.md` | Persona, identity, communication style | ✅ Yes |
| `instructions.md` | Behavioral rules, conventions, how to approach work | ✅ Yes |
| `rules.md` | Hard constraints, non-negotiables | ✅ Yes |
| `skills/` | Skill definitions for this profile | ✅ Yes |
| `index.md` | Navigation overview | ✅ Yes |
| `log.md` | Changelog / activity log | ✅ Yes |

**Not in system/ (stays runtime-local, NOT in mnemo repo):**
- `config.yaml` (model, provider, API keys) → local per machine/runtime
- `sessions/` (runtime session logs) → local per runtime
- `cron/` (scheduled task state) → local per runtime
- Any file containing secrets or ephemeral runtime state

Runtime-specific configs use the `config.yaml.example` pattern already established in the repo (template in mnemo, actual values local-only).

---

## 5. Tag System (Boilerplate Prevention)

### 5.1 Principle

Common instructions, rules, and skills that apply across multiple profiles live **once** in `_all/`. Profiles reference them instead of duplicating content.

### 5.2 Reference Syntax

In any profile file, reference shared content via wikilink syntax:

```markdown
# instructions.md (example)

[[_all/base-conventions]]
[[_all/sensitivity-handling]]

## Profile-specific instructions
[only what's unique to this profile]
```

### 5.3 _all/ Structure

```
_all/
├── base-conventions.md      ← universal conventions (markdown format, frontmatter, etc.)
├── sensitivity-handling.md  ← how to handle sensitivity tags (PUBLIC/INTERNAL/SENSITIVE/PRIVATE)
├── git-workflow.md           ← branch-per-layer, --no-ff merge conventions
└── skills/
    └── <shared-skill-name>/ ← skills used by multiple profiles
```

### 5.4 Resolution at Runtime

The per-runtime adapter (Hermes/OpenCode — details in Sub-project C) resolves `[[wikilinks]]` when assembling context for an agent run. For MVP, a small render script can inline `_all/` references into a profile's assembled context before passing to the runtime.

---

## 6. CLAUDE.md Convention per Profile

Each profile's `CLAUDE.md` is the **lean entry point** — it does NOT duplicate content, only points to it:

```markdown
# <ProfileName>

[[_all/base-conventions]]

## Identity
→ soul.md

## How I work
→ system/instructions.md

## Constraints
→ system/rules.md

## Current focus
→ todos/ | plans/

## Skills
→ system/skills/

## Projects
→ projects/
```

Maximum ~30 lines. If it grows longer, something is being duplicated that belongs in a referenced file.

---

## 7. Runtime-Agnostic Design & Secrets Boundary

### 7.1 What mnemo Owns

mnemo's `agent-memory/` is the **source of truth** for everything shareable and versionable: identity, instructions, rules, skills, todos, ideas, plans, project context.

### 7.2 What the Runtime Owns

The agent runtime (Hermes, OpenCode, or any future runtime) owns:
- Model/provider selection and API keys (`config.yaml`)
- Session state, conversation history
- Cron schedules and job queues
- Any ephemeral or machine-specific state

### 7.3 Adapter Pattern

A thin per-runtime adapter bridges mnemo's generic schema to the runtime's expected format. Adapter implementation is deferred to Sub-project C (Orchestration). The adapter's job:
- Read mnemo's `system/` files
- Resolve `[[wikilink]]` references
- Map to runtime-specific structure (e.g. skills/ → `~/.hermes/profiles/X/skills/` or OpenCode equivalent)
- Inject assembled context into the runtime's agent invocation

This is the same thin-adapter pattern already documented in the spec for Gortex/PageIndex (tool APIs change; core architecture doesn't).

### 7.4 Germany / GDPR Note

Secrets management via professional providers (e.g. Bitwarden) is mandatory — not optional. Secret values never enter the mnemo repo under any circumstances.

---

## 8. Optimization Flow (No Dedicated Folder)

Optimization insights surface through the existing layer architecture:

```
Session ends
    → session-memory/<session>/agent-o.md    (LLM-generated optimization ideas from session context)
         → triage (brain-memory-manager)
              → relevant profile's ideas/    (agent-specific improvements)
                   → if pattern confirmed across sessions
                        → longterm-memory/patterns/   (permanent, curated knowledge)
```

No dedicated `optimization/` folder needed. `plans/` are living documents and get updated when an optimization becomes an actionable plan.

---

## 9. First Implementation Target: researcher category

The `researcher/` category is the first to be fully fleshed out, serving as the template for all others.

### Priority order:
1. `researcher/manager/` — fully scaffold system/ (soul.md, instructions.md, rules.md, skills/) + seed todos/
2. `researcher/reviewer/` — scaffold system/
3. `researcher/default/` — scaffold system/
4. `_all/` — write base-conventions.md, sensitivity-handling.md as first shared content
5. Remaining researcher sub-profiles (food, llm/*) — scaffold system/ once template is stable

### First todo for researcher/manager:
```yaml
---
title: "Research how Hermes manages secrets via Bitwarden"
status: open
priority: high
project: mnemo
created: 2026-06-30
tags: [secrets, bitwarden, hermes, security, germany, gdpr]
---
Research the Bitwarden secrets integration in Hermes:
- How does Hermes access Bitwarden secrets at runtime?
- Which secret types are managed (API keys, tokens, passwords)?
- How can this pattern be adapted for the mnemo runtime-agnostic design?
- What are the GDPR implications for German users?
Output: recommendation for secrets management in mnemo's agent infrastructure.
```

---

## 10. Open Questions (Deferred)

| Topic | Deferred To |
|---|---|
| Runtime adapter implementation (Hermes, OpenCode) | Sub-project C |
| knowledge-memory layer schema detail | Sub-project B |
| Router logic (Cleaner→Tagger→Router pipeline) | Sub-project D |
| Multi-LLM orchestration study + repo | Sub-project E |
| Wikilink resolution tooling / render script | Sub-project C (or implementation plan for A) |
| `projects/<Name>/` sync mechanism from project-memory | Sub-project B/C |

---

## 11. Decision Log

| Decision | Rationale |
|---|---|
| Manager + Reviewer generalized to ALL categories | Consistency, avoids ad-hoc retroactive additions, enables uniform orchestration pattern |
| Manager = dispatcher only, does not execute | Clean separation of routing vs. execution; mirrors brain-memory-manager's orchestrator role |
| Default = optional (not every category needs one) | Some categories (e.g. memory-manager) have no meaningful catch-all; avoid forced abstraction |
| No dedicated optimization/ folder | Optimization emerges from session-memory → ideas/ → longterm-memory/patterns/; no redundant layer |
| plans/ = living execution plans (not angenommene/static) | Plans evolve with work; static snapshots belong in session-memory |
| projects/ = profile-filtered context from project-memory | No duplication; projects/ is a read-oriented cache/view, not an independent data store |
| Runtime-agnostic schema in mnemo | Enables Hermes AND OpenCode (and future runtimes) without schema changes; adapter pattern per runtime |
| Secrets never in mnemo repo | GDPR / legal requirement (Germany); professional providers (Bitwarden) mandatory |
| config.yaml.example pattern for runtime config | Consistent with existing repo convention; actual values stay local |
| _all/ for shared content + wikilink references | Single source of truth for common rules/conventions; no copy-paste drift across 20+ profiles |
