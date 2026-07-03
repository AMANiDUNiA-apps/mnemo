# Brain Memory Manager — Specification (Work in Progress)

> **Status:** In progress — refined via sequential clarification
> **Last Updated:** 2026-07-03 (v0.2 — 8-layer alignment with the live instance)
> **Based on:** Private original draft notes (not included in this repo)

---

## 1. Overview & Guiding Principles

**Purpose:** A multi-layered memory system that distributes and synchronizes information across storage layers, so that every agent achieves the best possible result with minimal context/token consumption.

**Principles:**
- **Layer Isolation** — Each layer has a clear purpose, ownership & access rules
- **Token Minimization** — Agents load only their relevant subset (via tags, namespaces, MCP)
- **Human-Readable** — Markdown as primary format, JSON for indexes
- **Plug & Play** — Entire system installable as a package (future vision)
- **Observability** — Langfuse integration for tracing, evaluation, privacy control

---

## 2. Layer Architecture (8 Layers)

Six content layers plus two cross-cutting layers (`sensitivity-layer`, `telemetry`).

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER-MEMORY          → User-Profile, Preferences, History    │
├─────────────────────────────────────────────────────────────────┤
│ 2. AGENT-MEMORY         → AgentOS: Building Blocks + Profiles   │
├─────────────────────────────────────────────────────────────────┤
│ 3. SESSION-MEMORY       → Raw Sessions + PageIndex Analytics    │
├─────────────────────────────────────────────────────────────────┤
│ 4. PROJECT-MEMORY       → Project Goals, Stack, ADRs, TODOs     │
├─────────────────────────────────────────────────────────────────┤
│ 5. KNOWLEDGE-MEMORY     → Repos, Wiki, RAG (persistent)         │
├─────────────────────────────────────────────────────────────────┤
│ 6. LONGTERM-MEMORY      → Promoted Session Insights             │
╞═════════════════════════════════════════════════════════════════╡
│ 7. SENSITIVITY-LAYER    → Cross-cutting: tags + enforcement     │
├─────────────────────────────────────────────────────────────────┤
│ 8. TELEMETRY            → Token/cost tracking, traces           │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Flows (decided)

| From | To | Mechanism |
|------|-----|-----------|
| `session-memory` | `longterm-memory` | **Hybrid Promotion** — auto-score as suggestion + human confirm (one-click) — default: "decide later" — **after 28 days of inactivity: auto-promotion (no delete)** |
| `project-memory` | `knowledge-memory/wiki-knowledge` | Reference only (repos mirrored into `knowledge-memory/repo-knowledge/`) |
| `knowledge-memory/repo-knowledge` | `knowledge-memory/rag-knowledge` | Incremental indexing (LightRAG, RAG Anything) |
| `session-memory` | `knowledge-memory/wiki-knowledge` | **Not direct** — only via `longterm-memory` |

---

## 3. Folder Structure (complete, v0.2 = live naming)

```
brain-memory/
├── config.yaml                  ← layer→path map, overlay, enforcement (see config.yaml.example)
├── index.md                     ← layer overview table
│
├── user-memory/
│   ├── index.md
│   ├── profile-xs.md / -s.md / -m.md / -l.md / -xl.md
│   └── topics/
│       ├── preferences.md
│       ├── projects.md
│       └── history.md
│
├── agent-memory/                ← "AgentOS": building blocks + profiles (all Markdown + YAML)
│   ├── index.md
│   ├── _all/                    ← shared conventions, build guide, ID registry, validator, fail captures
│   ├── agent-runtime/           ← runtime definitions (claude-code, hermes, …)
│   ├── agent-llms/              ← model/provider definitions (roles, best_for)
│   ├── agent-skills/            ← shared / distilled skills
│   ├── agent-mcps/              ← MCP server definitions
│   ├── agent-clis/              ← CLI tool definitions
│   └── agent-profiles/
│       └── [group]/[name]/      ← e.g. swift-agents/swift-metal/
│           ├── CLAUDE.md        ← frontmatter composes blocks by ID + policy
│           ├── core/            ← soul.md, instructions.md, rules.md, log.md
│           ├── todos/           ← one .md per todo, YAML frontmatter
│           ├── ideas/
│           └── plans/
│
├── session-memory/
│   ├── index.md                 ← overview of all sessions
│   └── [SessionName-or-ID]/     ← e.g. "2026-06-29_example-session"
│       ├── raw.md               ← full session (Markdown export)
│       ├── tree-index.json      ← PageIndex tree index
│       ├── summary-xs.md … -xl.md
│       ├── workedOn.md · usedTools.md · fails.md
│       ├── learnings.md · learned.md
│       ├── agent-o.md · skills.md · human-ai.md
│
├── project-memory/
│   ├── index.md
│   └── [ProjectName]/
│       ├── goals.md · stack.md · conventions.md · todos.md
│       ├── adrs/
│       └── [ProjectName]-xs.md … -xl.md
│
├── knowledge-memory/
│   ├── repo-knowledge/          ← source repos (Gortex-indexed)
│   │   └── [RepoName]/
│   │       ├── index.json       ← Gortex tree index
│   │       ├── [RepoName]-xs.md … -xl.md
│   │       └── raw/             ← original files (optional)
│   ├── wiki-knowledge/          ← LLM-maintained wiki (Karpathy pattern)
│   │   └── [topic]/
│   │       ├── index.md · log.md · CLAUDE.md
│   │       └── summary-xs.md … -xl.md
│   └── rag-knowledge/           ← RAG indices (wikirag, RAG Anything, …)
│
├── longterm-memory/             ← promoted session insights
│   ├── index.md
│   ├── insights/[Topic]/
│   │   ├── insight-xs.md … -xl.md
│   │   └── source-session.md    ← reference to original session
│   └── patterns/                ← recurring patterns, best practices
│
├── sensitivity-layer/           ← cross-cutting: sensitivity tags + policy
│   ├── index.md                 ← tag definitions + enforcement rules
│   ├── config.yaml              ← policies, feature flags (see config.yaml.example)
│   └── index.db                 ← SQLite path→tag map for runtime checks (planned)
│
└── telemetry/
    └── token-usage.jsonl        ← per-call token/cost tracking (planned)
```

The live instance is the source of truth for naming; the public skeleton mirrors
it (see `docs/overlay-architecture.md` for the two-repo overlay contract).

---

## 4. Tagging & Sensitivity Schema

### Sensitivity Tags (4 levels)

| Tag | Meaning | LLM Access | Logging |
|-----|---------|------------|---------|
| `[PUBLIC]` | Free to forward, external models OK | ✅ All | ✅ Full |
| `[INTERNAL]` | Local models only, no cloud LLM | ✅ Local only | ✅ Metadata |
| `[SENSITIVE]` | Never in LLM context, structural ref only | ❌ Never | ❌ No payload |
| `[PRIVATE]` | Absolutely local, no logging | ❌ Never | ❌ Nothing |

### Storage & Enforcement (decided)

- **Frontmatter** in every memory file (YAML: `sensitivity: PUBLIC`)
- **Index DB** (`sensitivity-layer/index.db`) for fast runtime checks
- **Enforcement** via the `brain_manager` skill: before every LLM call → checks tags → filters/redacts
- **Opt-in only** — this layer is only passed to an agent/LLM **on request**
- **Feature flag** — fully toggleable (`sensitivity-layer/config.yaml`)

### Topic Tags (additional)
- `[SKILL]`, `[MCP]`, `[CLI]`, `[FOR_ALL]`, `[FOR_AGENT:<name>]`, `[PROJECT:<name>]`

---

## 5. Doc-Size Tiering (xs–XL) + Token Budgets

| Size | Purpose | ~Tokens | Layer Examples |
|------|---------|---------|-----------------|
| **xS** | System prompts, reference snippets | 50–150 | `profile-xs.md`, `skills-xs.md` |
| **S** | Quick context, agent briefing | 150–500 | `summary-s.md`, `workedOn.md` |
| **M** | Normal context, standard tasks | 500–2,000 | `summary-m.md`, `conventions.md` |
| **L** | Detailed context, complex tasks | 2,000–8,000 | `summary-l.md`, `adrs/` |
| **XL** | Complete documentation, onboarding | 8,000–32,000 | `summary-xl.md`, `raw.md` |

**Budget per agent/task:** defined in `agent-memory/_all/budgets.yaml` (future).

---

## 6. Pipeline: Ingestion → Cleaner → Tagger → Layer-Routing

```
~/files/raw/ (Input)
       │
       ▼
┌──────────────────┐
│ CLEANER (Skill)  │  → Encoding, whitespace, boilerplate, PII redaction
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ TAGGER (Skill)   │  → Frontmatter: sensitivity, topic-tags, layer-routing, doc-size
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ ROUTER (Skill)   │  → Moves to brain-memory/<layer>/...
└──────────────────┘
```

**Implementation (decided): Hybrid**
- **Logic** lives in the `brain_manager` skills (`cleaner`, `tagger`, `router`), runtime-agnostic
- **Trigger** via OS: cron + inotify (systemd path unit) on `~/files/raw/`
- **Langfuse integration** — tracing of all pipeline steps (optional, via config)

---

## 7. Tools & Services Matrix (status: tools 1 & 2 clarified)

| Tool | Layer | Input | Output | Trigger | Status |
|------|-------|-------|--------|---------|--------|
| **Gortex** | `knowledge-memory/repo-knowledge/` | Code files (Swift, Python, TS, etc.) | MCP resources (live) + tree index (`index.json`) + **Markdown xs–XL (via exporter)** | Post-clone (immediate) + daily cron (incremental) + weekly/on-demand (full rebuild) | ✅ Clarified |
| **PageIndex** | `session-memory/` → `longterm-memory/` | Raw sessions (Markdown) + wiki docs | Tree index (JSON) + summaries xs–XL + analytics files (workedOn, usedTools, fails, learnings, learned, agent-o, skills, human-ai) | Session end (auto) + on-demand | 🔄 Partially clarified |
| **LLM-Wiki** (Karpathy pattern) | `knowledge-memory/wiki-knowledge/` | Markdown wikis + sources | Persistent, cross-referenced wiki (LLM-maintained) | Ingest (human-driven) + lint (cron) | ⏳ Open |
| **Understand-Anything** | `knowledge-memory/repo-knowledge/` & `wiki/` | Code + docs | ADRs, summaries, dependency graphs | On-demand (agent/CI) + PR hook | ⏳ Open |
| **LightRAG** | `knowledge-memory/rag-knowledge/` | Wiki + repo docs | Graph-RAG index + query API | Incremental (watcher) + cron (full rebuild) | ⏳ Open |
| **RAG Anything** | `knowledge-memory/rag-knowledge/` | Multi-modal files (PDF, images, tables, code) | Multi-modal RAG index | On-demand + cron | ⏳ Open |

### Gortex Details (decided)
- **Scope:** all repos in `~/github/loadedrepos/`
- **No `.git` required** — parses source files directly (Tree-Sitter)
- **MCP live access** for agents (context-minimized: "give me `APIClient.request`" → snippet)
- **Swift focus:** Tree-Sitter Swift + possibly SourceKit-LSP for type resolution
- **Markdown exporter** (skill/CLI): `gortex-export --format=markdown --output=knowledge-memory/repo-knowledge/<name>/`

### PageIndex Details (partially decided)
- **Input:** sessions as **Markdown** (better readability, `#` headings for hierarchy)
- **Analytics files:** **LLM-generated** (prompt + tree index as context)
- **Additional questions** (agent-o, skills, human-AI): **dynamic prompts**
- **Output location:** `session-memory/<SessionName>/` with all files
- **Open:** promotion criteria → `longterm-memory` (score? review? TTL?)

---

## 8. Agent Access Patterns (partially clarified)

> How does an agent query only its relevant subset?

**Read permissions (decided):**

| Layer | Read Access |
|-------|-------------|
| `user-memory` | **Only** `brain-user-memory` + `brain-memory-manager` |
| `session-memory` | **Only** `brain-session-memory` + `brain-memory-manager` |
| All others | **All profiles** (read-only) + `brain-memory-manager` |

**Access patterns:**

- **Namespace prefix:** `agent-memory/_all/`, `agent-memory/<AgentName>/`
- **Tag filter:** `[FOR_AGENT:system_developer]` + `[FOR_ALL]`
- **MCP resources:** `gortex://`, `pageindex://`, `lightrag://` (live, token-minimal)
- **Doc-size budget:** agent loads at most X tokens per layer (xs→S→M... up to budget) — **tracked per call** (model, provider, thinking mode, input/output tokens, cost, layer, doc sizes) → Langfuse + JSONL
- **Layer selection:** agent declares the layers it needs → `brain-memory-manager` returns the subset

**Open:** budget details per agent type, layer-selection configuration.

---

## 9. Sync / Replication / Retention / TTL Rules (open)

| Layer | Retention | Sync | TTL |
|-------|-----------|------|-----|
| `session-memory` | Raw: unlimited (archive) | PageIndex after session end | — |
| `longterm-memory` | Unlimited (curated) | Manual promotion | — |
| `knowledge-memory` | Unlimited | Incremental (watcher) | — |
| `user/agent-memory` | Unlimited | On-change | — |

**Open:** `session-memory` raw files — compress after X days? TTL for analytics?

---

## 10. Governance (partially clarified)

**Architecture: layer = profile**

| Layer | Profile | Responsibility |
|-------|--------|---------------|
| `user-memory` | `brain-user-memory` | User profile, preferences, history |
| `agent-memory` | `brain-agent-memory` | Skills, MCPs, CLIs, agent configs |
| `session-memory` | `brain-session-memory` | Raw sessions, PageIndex, analytics |
| `project-memory` | `brain-project-memory` | Goals, stack, ADRs, TODOs |
| `knowledge-memory` | `brain-knowledge-memory` | Repos, wiki, RAG |
| `longterm-memory` | `brain-longterm-memory` | Promoted insights, patterns |
| `sensitivity-layer` | `brain-sensitivity` | Tags, enforcement, policies |
| **Orchestrator** | **`brain-memory-manager`** | Delegation, audit log, cross-layer ops |

**Write permissions (decided):** each profile writes **only** to its own layer. `brain-memory-manager` orchestrates via `delegate_task` and merges git branches.

**Audit log:** `brain-memory-manager` logs every ingest/promotion to `AUDIT.log` (who, what, where, when, which branch, merge commit).

**Cross-layer reads:** all profiles may read all layers (except `user-memory` + `session-memory` → owner + manager only).

**Index strategy:** central index (`brain-memory/index.md`, manager) + profile-specific indexes (`brain-memory/<layer>/index.md`, owning profile).

**Promotion flow:** `brain-session-memory` detects promotion-worthy content → `delegate_task` → `brain-longterm-memory`, and `brain-memory-manager` logs it.

**Git workflow:** each profile works on its own branch `ingest/<layer>-<timestamp>` → `brain-memory-manager` merges `--no-ff` → `main` + tag.

**Skills location (recommendation: hybrid):** core skills (`cleaner`, `tagger`, `router`, `pageindex-runner`) live in a **shared library** (`~/brain-memory-skills/`) — profiles import them via `delegate_task` + `toolsets`.

**Backup:** Restic/Borg (daily) + rclone to Google Drive (5TB, interim) → later Syncthing to a home NAS.

**Migration:** versioned migration skills (`brain_manager migrate --from=v1 --to=v2`) — one git commit per migration.

**Backup verification:** monthly `restic check --read-data-subset=5%` + `rclone check` — alert on failure.

---

## Appendix: Examples

### Frontmatter (standard)
```yaml
---
title: "Gortex Setup Session"
date: 2026-06-29
session_id: "2026-06-29_gortex-setup"
layer: "session-memory"
sensitivity: "INTERNAL"
tags: [SKILL, MCP, FOR_AGENT:system_developer, PROJECT:brain-memory]
doc_size: "M"
source: "agent-export"
---
```

### Index file pattern (`index.md`)
```markdown
# Session Memory Index

| Session | Date | Topic | Size | Tags | Promoted |
|---------|------|-------|------|------|----------|
| 2026-06-29_gortex-setup | 2026-06-29 | Gortex MCP Config | M | [SKILL][MCP] | ❌ |
```

### Example: Gortex MCP Config
```yaml
# <agent-runtime>/config.yaml
mcp_servers:
  gortex:
    command: "gortex"
    args: ["mcp", "--index-dir", "~/brain-memory/knowledge-memory/repo-knowledge"]
    env:
      GORTEX_MODEL: "gpt-4o-mini"
```

---

## Open Questions (Checklist)

- [ ] **Agent Access Patterns** — budget details per agent type, layer-selection configuration
- [ ] **Sync/Retention/TTL** details per layer (compression, TTL for analytics)
- [ ] **LLM-Wiki (Karpathy)** integration & schema design
- [ ] **Understand-Anything / LightRAG / RAG Anything** roles & triggers
- [ ] **Doc-Size Budgets** per agent/task
- [ ] **Langfuse Config** (proxy vs. OTLP, privacy settings per sensitivity tag)
- [ ] **Core-Skills Library Design** — interface, shared vs. profile-specific, versioning
- [ ] **Plug&Play Package** feasibility (future)
- [ ] **Migration & Versioning Strategy** — schema changes, git tags, upgrade path
- [ ] **Telemetry Config Details** — Langfuse OTLP, privacy settings, token-tracking JSONL schema

---

## Decision Log (excerpt)

| Topic | Decision | Rationale |
|-------|--------------|------------|
| Layer Count | 6 layers + sensitivity-layer | `longterm-memory` added for promoted insights |
| Sensitivity Storage | Frontmatter + SQLite index DB | Human-readable + runtime performance |
| Pipeline | Hybrid: skills + OS triggers + Langfuse | Separation of logic/orchestration, observability |
| Gortex Output | MCP live + tree-index JSON + Markdown export | Agents (token-efficient) + humans (overview) |
| PageIndex Input | Markdown sessions | Readability, `#` headings for hierarchy |
| PageIndex Analytics | LLM-generated | Context-aware, flexible |
| Session Output Path | `session-memory/<SessionName>/` | Human-readable, grouped |
| Promotion Flow | Hybrid: score suggestion + human confirm, 28d auto-promote | Balance autonomy/control, no data loss |
| Read Permissions | user/session: owner+manager only; rest: all read-only | Privacy for sensitive layers |
| Index Strategy | Central (manager) + profile-specific | Cross-layer overview + layer detail |
| Git Workflow | Per-layer branches, manager merges --no-ff | Atomic ingests, full history, rollback |
| Skills Location | Hybrid: core in shared lib, business logic per profile | No duplication, true isolation |
| Backup | Restic + rclone (GDrive interim) → Syncthing (NAS) | 3-2-1, versioning, dedup, encryption |
| Telemetry | Langfuse OTLP + JSONL Token-Tracking | Free-model observability, cost tracking, evaluation ready |
| Layer Naming v0.2 (2026-07-03) | 8 top-level layers; `*-knowledge` subfolders; agent-memory = AgentOS blocks + profiles | Live instance is naming source of truth; public skeleton aligned (overlay-v1) |
