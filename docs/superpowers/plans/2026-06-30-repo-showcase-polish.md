# Repo Showcase Polish Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up and polish the mnemo repo (doc-only, no implementation code) so it's safe and compelling as a public portfolio piece — removing a real personal-data leak, dropping references to a private/unreleased "Hermes Agent" runtime, translating the spec fully to English, and adding Why/Roadmap/Credits context to the README.

**Architecture:** This is a documentation-only change set across `README.md`, `CONTRIBUTING.md`, `brain-memory-manager-spec.md`, two skeleton `index.md` files, one example data file, and two new GitHub issue templates. There is no code, so "tests" in this plan are `grep` verification steps confirming leaked strings are gone and no template/placeholder markers were left behind.

**Tech Stack:** Markdown, git, `grep`.

**Reference:** Design doc at `docs/superpowers/specs/2026-06-30-repo-showcase-polish-design.md`.

---

### Task 1: Remove the real personal data leak in `preferences.md`

**Files:**
- Modify: `brain-memory/user-memory/topics/preferences.md`

- [ ] **Step 1: Replace the file's real personal content with a clearly-labeled generic example**

Use the Edit tool (or equivalent) to replace the entire body of `brain-memory/user-memory/topics/preferences.md` with:

```markdown
---
title: "User Preferences"
sensitivity: "INTERNAL"
tags: ["USER", "PREFERENCES", "M"]
doc_size: "M"
layer: "user-memory"
---

# User Preferences

> **Note:** This file is an illustrative example of the schema, not real user data. Replace it with your actual preferences when adopting this template — and remember it's tagged `INTERNAL`, so don't commit a real one to a public repo.

## Communication Style
- **Language:** English (primary), German (secondary)
- **Tone:** Direct, technical, concise
- **Detail Level:** High — prefers full context over summaries

## Tooling Preferences
- **Editor:** VS Code / Cursor
- **Terminal:** your terminal of choice
- **Shell:** zsh
- **Package Manager:** uv (Python), npm/pnpm (Node), brew (macOS)
- **Container Runtime:** Docker / Podman
- **Version Control:** Git (conventional commits, --no-ff merges)

## Development Workflow
- **Branching:** Feature branches per ingest/task
- **Commits:** Atomic, signed, conventional format
- **Reviews:** Self-review before PR
- **Testing:** TDD where feasible, integration tests for infra
- **Documentation:** Markdown-first, living docs in repo

## AI/LLM Preferences
- **Primary Models:** your preferred model providers
- **Local Inference:** llama.cpp, vLLM, Ollama
- **Observability:** Langfuse (self-hosted), JSONL token tracking
- **Privacy:** Sensitivity tags enforced, no cloud for SENSITIVE/PRIVATE
- **Token Tracking:** Per-call, per-layer, per-model

## Infrastructure
- **Provisioning:** Ansible, Terraform/OpenTofu
- **Orchestration:** Docker Compose, systemd
- **Monitoring:** Prometheus, Grafana, Loki, Alertmanager
- **Backup:** Restic + rclone, offsite sync
- **VPN/Mesh:** your mesh VPN of choice

## Knowledge Management
- **Primary:** mnemo brain-memory profiles (6 layers)
- **Secondary:** your notes app of choice
- **Code Navigation:** Gortex MCP
- **Session Analytics:** PageIndex
- **RAG:** LightRAG, RAG Anything
```

- [ ] **Step 2: Verify no leaked strings remain**

Run: `grep -n "Hermes TUI\|/home/jay\|Tailscale\|WireGuard" brain-memory/user-memory/topics/preferences.md`
Expected: no output (no matches)

- [ ] **Step 3: Commit**

```bash
git add brain-memory/user-memory/topics/preferences.md
git commit -m "docs: replace real personal preferences with generic example"
```

---

### Task 2: Remove private paths and Hermes Agent references from `CONTRIBUTING.md`

**Files:**
- Modify: `CONTRIBUTING.md:7`, `CONTRIBUTING.md:71-83`

- [ ] **Step 1: Generalize the "Current Status" line**

Old (`CONTRIBUTING.md:7`):
```markdown
**This repository currently contains the architecture specification and initial folder skeleton.** The implementation lives in the Hermes Agent profiles under `~/.hermes/profiles/brain-*/` and is actively being developed.
```

New:
```markdown
**This repository currently contains the architecture specification and initial folder skeleton.** The reference implementation is being developed as a set of agent profiles against this spec, and is actively in progress.
```

- [ ] **Step 2: Generalize the "Development Setup" section**

Old (`CONTRIBUTING.md:71-83`):
```markdown
## Development Setup

The implementation runs in **Hermes Agent** with specialized profiles:
- `brain-memory-manager` (orchestrator)
- `brain-user-memory`, `brain-agent-memory`, `brain-session-memory`
- `brain-project-memory`, `brain-knowledge-memory`, `brain-longterm-memory`
- `brain-sensitivity`

To run locally, you'll need:
1. Hermes Agent installed
2. The 8 brain-* profiles configured
3. MCP servers: `gortex`, `pageindex`, `lightrag`, `rag-anything`
4. Langfuse instance (optional, for telemetry)
```

New:
```markdown
## Development Setup

The reference implementation is designed to run as a set of specialized agent profiles, one per layer:
- `brain-memory-manager` (orchestrator)
- `brain-user-memory`, `brain-agent-memory`, `brain-session-memory`
- `brain-project-memory`, `brain-knowledge-memory`, `brain-longterm-memory`
- `brain-sensitivity`

To run locally, you'll need:
1. An LLM agent runtime that supports multiple profiles/sub-agents with filesystem access (e.g. Claude Code, or any agent framework that can load per-profile system prompts)
2. The 8 brain-* profiles configured per the spec
3. MCP servers: `gortex`, `pageindex`, `lightrag`, `rag-anything`
4. Langfuse instance (optional, for telemetry)
```

- [ ] **Step 3: Verify no leaked strings remain**

Run: `grep -ni "hermes\|/home/jay" CONTRIBUTING.md`
Expected: no output

- [ ] **Step 4: Commit**

```bash
git add CONTRIBUTING.md
git commit -m "docs: drop private Hermes Agent references from CONTRIBUTING"
```

---

### Task 3: Translate `brain-memory-manager-spec.md` fully to English and remove leaks

**Files:**
- Modify: `brain-memory-manager-spec.md` (full file rewrite)

- [ ] **Step 1: Replace the entire file content**

Use the Write tool to replace `brain-memory-manager-spec.md` in full with:

```markdown
# Brain Memory Manager — Specification (Work in Progress)

> **Status:** In progress — refined via sequential clarification
> **Last Updated:** 2026-06-30
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

## 2. Layer Architecture (6 Layers)

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER-MEMORY          → User-Profile, Preferences, History   │
├─────────────────────────────────────────────────────────────────┤
│ 2. AGENT-MEMORY         → Skills, MCPs, CLIs, Agent-Configs    │
├─────────────────────────────────────────────────────────────────┤
│ 3. SESSION-MEMORY       → Raw Sessions + PageIndex Analytics   │
├─────────────────────────────────────────────────────────────────┤
│ 4. PROJECT-MEMORY       → Project Goals, Stack, ADRs, TODOs    │
├─────────────────────────────────────────────────────────────────┤
│ 5. KNOWLEDGE-MEMORY     → Repos, Wiki, RAG (persistent knowledge)│
├─────────────────────────────────────────────────────────────────┤
│ 6. LONGTERM-MEMORY      → Promoted Session Insights            │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Flows (decided)

| From | To | Mechanism |
|------|-----|-----------|
| `session-memory` | `longterm-memory` | **Hybrid Promotion** — auto-score as suggestion + human confirm (one-click) — default: "decide later" — **after 28 days of inactivity: auto-promotion (no delete)** |
| `project-memory` | `knowledge-memory/wiki` | Reference only (repos mirrored into `knowledge-memory/repo/`) |
| `knowledge-memory/repo` | `knowledge-memory/rag` | Incremental indexing (LightRAG, RAG Anything) |
| `session-memory` | `knowledge-memory/wiki` | **Not direct** — only via `longterm-memory` |

---

## 3. Folder Structure (complete)

```
brain-memory/
├── user-memory/
│   ├── index.md
│   ├── profile-xs.md / -s.md / -m.md / -l.md / -xl.md
│   └── topics/
│       ├── preferences.md
│       ├── projects.md
│       └── history.md
│
├── agent-memory/
│   ├── index.md
│   ├── _all/                    ← applies to all agents
│   │   ├── skills-xs.md … -xl.md
│   │   └── mcps.md
│   └── [AgentName]/             ← agent-specific
│       └── [AgentName]-xs.md … -xl.md
│
├── session-memory/
│   ├── index.md                 ← overview of all sessions
│   └── [SessionName-or-ID]/     ← e.g. "2026-06-29_example-session"
│       ├── raw.md               ← full session (Markdown export)
│       ├── tree-index.json      ← PageIndex tree index
│       ├── summary-xs.md … -xl.md
│       ├── workedOn.md
│       ├── usedTools.md
│       ├── fails.md
│       ├── learnings.md
│       ├── learned.md
│       ├── agent-o.md           ← optimization ideas for agent-o
│       ├── skills.md            ← skill candidates
│       └── human-ai.md          ← human-AI connection insights
│
├── project-memory/
│   ├── index.md
│   └── [ProjectName]/
│       ├── goals.md
│       ├── stack.md
│       ├── conventions.md
│       ├── todos.md
│       ├── adrs/
│       └── [ProjectName]-xs.md … -xl.md
│
├── knowledge-memory/
│   ├── repo/
│   │   └── [RepoName]/
│   │       ├── index.json       ← Gortex tree index
│   │       ├── [RepoName]-xs.md … -xl.md
│   │       └── raw/             ← original files (optional, for reference)
│   ├── wiki/
│   │   ├── coding/
│   │   │   └── swift/
│   │   │       ├── index.md
│   │   │       ├── log.md
│   │   │       ├── CLAUDE.md    ← schema for LLM-Wiki (Karpathy pattern)
│   │   │       ├── summary-xs.md … -xl.md
│   │   │       └── [topic].md
│   │   └── food/
│   └── rag/
│       ├── coding/
│       ├── swift/
│       └── food/
│
├── longterm-memory/             ← promoted session insights
│   ├── index.md
│   ├── insights/
│   │   ├── [Topic]/
│   │   │   ├── insight-xs.md … -xl.md
│   │   │   └── source-session.md  ← reference to original session
│   └── patterns/                ← recurring patterns, best practices
│
└── sensitivity-layer/           ← separate layer for sensitivity tags
    ├── index.db                 ← SQLite: path → tag mapping (runtime enforcement)
    └── config.yaml              ← feature flags, default policies
```

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

## 7. Tools & Services Matrix (status: tools 1 & 2 finalized)

| Tool | Layer | Input | Output | Trigger | Status |
|------|-------|-------|--------|---------|--------|
| **Gortex** | `knowledge-memory/repo/` | Code files (Swift, Python, TS, etc.) | MCP resources (live) + tree index (`index.json`) + **Markdown xs–XL (via exporter)** | Post-clone (immediate) + daily cron (incremental) + weekly/on-demand (full rebuild) | ✅ Finalized |
| **PageIndex** | `session-memory/` → `longterm-memory/` | Raw sessions (Markdown) + wiki docs | Tree index (JSON) + summaries xs–XL + analytics files (workedOn, usedTools, fails, learnings, learned, agent-o, skills, human-ai) | Session end (auto) + on-demand | 🔄 Partially finalized |
| **LLM-Wiki** (Karpathy pattern) | `knowledge-memory/wiki/` | Markdown wikis + sources | Persistent, cross-referenced wiki (LLM-maintained) | Ingest (human-driven) + lint (cron) | ⏳ Open / backlog |
| **Understand-Anything** | `knowledge-memory/repo/` & `wiki/` | Code + docs | ADRs, summaries, dependency graphs | On-demand (agent/CI) + PR hook | ⏳ Open |
| **LightRAG** | `knowledge-memory/rag/` | Wiki + repo docs | Graph-RAG index + query API | Incremental (watcher) + cron (full rebuild) | ⏳ Open |
| **RAG Anything** | `knowledge-memory/rag/` | Multi-modal files (PDF, images, tables, code) | Multi-modal RAG index | On-demand + cron | ⏳ Open |

### Gortex Details (decided)
- **Scope:** all repos in `~/github/loadedrepos/`
- **No `.git` required** — parses source files directly (Tree-Sitter)
- **MCP live access** for agents (context-minimized: "give me `APIClient.request`" → snippet)
- **Swift focus:** Tree-Sitter Swift + possibly SourceKit-LSP for type resolution
- **Markdown exporter** (skill/CLI): `gortex-export --format=markdown --output=knowledge-memory/repo/<name>/`

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
    args: ["mcp", "--index-dir", "~/brain-memory/knowledge-memory/repo"]
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
```

- [ ] **Step 2: Verify translation completeness and no leaks**

Run: `grep -niE "hermes|/home/jay|für|über|während|während|möchte|geklärt|entschieden|offen\b" brain-memory-manager-spec.md`
Expected: no output (no German words, no Hermes/path leaks). Note: `grep -i` on German-specific characters/words catches residual untranslated text.

- [ ] **Step 3: Commit**

```bash
git add brain-memory-manager-spec.md
git commit -m "docs: translate spec to English, remove Hermes/private path references"
```

---

### Task 4: Mark not-yet-created files as planned in skeleton `index.md` files

**Files:**
- Modify: `brain-memory/agent-memory/index.md`
- Modify: `brain-memory/user-memory/index.md`

- [ ] **Step 1: Update `brain-memory/agent-memory/index.md`**

Replace the full file content with:

```markdown
# Agent Memory Index

| Path | Size | Description | Status | Updated |
|------|------|--------------|--------|---------|
| _all/skills-index.md | M | All available skills overview | planned | — |
| _all/mcps.md | S | All MCP server configurations | planned | — |
| _all/skills-xs.md | xS | Minimal skills reference | planned | — |
| _all/skills-s.md | S | Quick skills reference | planned | — |
| _all/skills-m.md | M | Standard skills reference | planned | — |
| _all/skills-l.md | L | Detailed skills reference | planned | — |
| _all/skills-xl.md | XL | Complete skills reference | planned | — |
| [AgentName]/ | — | Agent-specific configurations | planned | — |

## Shared (_all/)
Common to all agents — skills, MCPs, CLIs available globally. None of the files above exist yet; this table documents the intended structure.

## Agent-Specific (<AgentName>/)
Per-agent overrides and specialized configs (e.g., `system_developer/`, `researcher/`, `docker/`). Not yet populated.
```

- [ ] **Step 2: Update `brain-memory/user-memory/index.md`**

Replace the full file content with:

```markdown
# User Memory Index

| File | Size | Description | Status | Updated |
|------|------|--------------|--------|---------|
| profile-xs.md | xS | Minimal user profile | example | — |
| profile-s.md | S | Standard user profile | example | — |
| profile-m.md | M | Detailed user profile | planned | — |
| profile-l.md | L | Full user profile | planned | — |
| profile-xl.md | XL | Complete user profile | planned | — |
| topics/preferences.md | M | User preferences | example | — |
| topics/projects.md | S | Tracked projects | planned | — |
| topics/history.md | L | Interaction history | planned | — |
```

- [ ] **Step 3: Verify referenced files match reality**

Run:
```bash
test -f brain-memory/user-memory/profile-xs.md && echo "profile-xs.md exists (matches 'example')"
test -f brain-memory/user-memory/profile-m.md || echo "profile-m.md absent (matches 'planned')"
```
Expected: both lines print, confirming the index now accurately reflects the filesystem.

- [ ] **Step 4: Commit**

```bash
git add brain-memory/agent-memory/index.md brain-memory/user-memory/index.md
git commit -m "docs: mark not-yet-created skeleton files as planned in index tables"
```

---

### Task 5: Add Why / Roadmap / Credits sections, ToC, and badges to `README.md`

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add badges under the title**

Old (`README.md:1-3`):
```markdown
# mnemo — LLM Brain Memory Manager

> **A multi-layered memory system for LLM agents** — Distributes and synchronizes information across specialized memory layers so each agent achieves optimal results with minimal context/token consumption.
```

New:
```markdown
# mnemo — LLM Brain Memory Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-early%20development-orange.svg)](#roadmap)

> **A multi-layered memory system for LLM agents** — Distributes and synchronizes information across specialized memory layers so each agent achieves optimal results with minimal context/token consumption.

## Table of Contents

- [Overview](#overview)
- [Why mnemo?](#why-mnemo)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Tools & Services](#tools--services)
- [Pipeline](#pipeline)
- [Git Workflow](#git-workflow)
- [Backup Strategy](#backup-strategy)
- [Telemetry](#telemetry)
- [Getting Started](#getting-started)
- [Roadmap](#roadmap)
- [Credits & Acknowledgments](#credits--acknowledgments)
- [Contributing](#contributing)
- [License](#license)
```

- [ ] **Step 2: Insert the "Why mnemo?" section after the layer diagram, before "## Key Features"**

Find this line in `README.md` (currently around line 26):
```markdown
## Key Features
```

Insert immediately before it:
```markdown
## Why mnemo?

mnemo grew out of a simple, recurring problem: anyone building with LLM agents eventually needs structured, layered memory — without it, context either grows unbounded (cost, latency) or stays too shallow (the agent forgets everything between sessions). This repository is the architecture layer underneath a larger goal: a **native macOS app** (Vapor backend, SwiftData) that uses this memory system end-to-end — open source, MIT licensed. A fully native Swift reimplementation of MinerU (used by RAG Anything for multi-modal parsing) isn't practical right now, so that part of the RAG pipeline stays dependent on the existing Python ecosystem for the time being.

```

- [ ] **Step 3: Insert the "Roadmap" section before "## Contributing"**

Find this line in `README.md` (currently around line 145):
```markdown
## Contributing
```

Insert immediately before it:
```markdown
## Roadmap

- ✅ Architecture spec defined; constituent tools brought up and tested on a vServer
- 🔄 Implementation tests of individual layers/tools
- 🔜 "Swift Tutor" feasibility study: feed mnemo Swift tutorials/docs and have it generate tutorials — the first building block toward **thirdwiki**, fillable and navigable knowledge bases meant to strengthen the human-AI bond
- 🔜 Evaluate [AFFiNE](https://github.com/toeverything/AFFiNE) as a self-hosted control layer to drive mnemo's tools from a UI (final tool selection still open)
- 🔜 Native macOS app (Vapor + SwiftData)

## Credits & Acknowledgments

mnemo composes existing open-source tools rather than reimplementing them. Credit where it's due:

| Tool | Purpose |
|------|---------|
| [Gortex](https://github.com/zzet/gortex) | Code-intelligence graph for token-efficient code search |
| [PageIndex](https://github.com/VectifyAI/PageIndex) | Vectorless, reasoning-based RAG (tree index instead of embeddings) |
| [LLM-Wiki Pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) | Andrej Karpathy's pattern for LLM-maintained wikis |
| [Apple Docs Offline Archive](https://github.com/OxADD1/Apple-Developer-Documentation-Offline-Archive) | Offline archive of Apple Developer docs (Markdown/JSON) |
| [Understand-Anything](https://github.com/Egonex-AI/Understand-Anything) | Turns code into an interactive, searchable knowledge graph |
| [Crawl4AI](https://github.com/unclecode/crawl4ai) | LLM-optimized web crawling |
| [Qdrant](https://github.com/qdrant/qdrant) | Vector database |
| [Chonkie](https://github.com/feyninc/chonkie) | Lightweight chunking library for RAG pipelines |
| [RAG Anything](https://github.com/HKUDS/RAG-Anything) | Multi-modal RAG pipeline (incl. MinerU) |
| [LightRAG](https://github.com/HKUDS/LightRAG) | Graph-based RAG pipeline |
| [Langfuse](https://github.com/langfuse/langfuse) | LLM observability/tracing |
| [AFFiNE](https://github.com/toeverything/AFFiNE) | Self-hosted, Notion-like workspace — candidate control layer |
| [CLI-Anything](https://github.com/HKUDS/CLI-Anything) | Turns existing software into agent-native CLIs (e.g. Blender, GIMP, LibreOffice) without GUI automation |

```

- [ ] **Step 4: Verify the new sections are present and no leaks were introduced**

Run: `grep -n "^## " README.md`
Expected output includes, in order: `## Table of Contents`, `## Overview`, `## Why mnemo?`, `## Key Features`, `## Architecture`, `## Tools & Services`, `## Pipeline`, `## Git Workflow`, `## Backup Strategy`, `## Telemetry`, `## Getting Started`, `## Roadmap`, `## Credits & Acknowledgments`, `## Contributing`, `## License`

Run: `grep -ni "hermes\|/home/jay" README.md`
Expected: no output

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: add Why, Roadmap, Credits sections, ToC and badges to README"
```

---

### Task 6: Add GitHub issue templates

**Files:**
- Create: `.github/ISSUE_TEMPLATE/bug_report.md`
- Create: `.github/ISSUE_TEMPLATE/spec_clarification.md`

- [ ] **Step 1: Create the bug report template**

```markdown
---
name: Bug report
about: Report a problem with the spec, folder structure, or templates
title: "[Bug] "
labels: bug
---

## What's wrong?

A clear description of the issue.

## Where

- File/path:
- Section (if spec):

## Expected vs. actual

What you expected, and what you got instead.

## Additional context

Anything else that's relevant (links, screenshots, related issues).
```

- [ ] **Step 2: Create the spec clarification template**

```markdown
---
name: Spec clarification
about: Ask a question about or propose a change to the architecture spec
title: "[Spec] "
labels: spec
---

## Section

Which part of `brain-memory-manager-spec.md` does this concern?

## Question / Proposed change

Describe the ambiguity, gap, or change you'd like to propose.

## Rationale

Why does this matter? What's the impact of leaving it unresolved?
```

- [ ] **Step 3: Verify both files exist**

Run: `ls .github/ISSUE_TEMPLATE/`
Expected: `bug_report.md` and `spec_clarification.md` listed

- [ ] **Step 4: Commit**

```bash
git add .github/ISSUE_TEMPLATE/bug_report.md .github/ISSUE_TEMPLATE/spec_clarification.md
git commit -m "docs: add bug report and spec clarification issue templates"
```

---

### Task 7: Final repo-wide verification

**Files:** none (verification only)

- [ ] **Step 1: Confirm no leaked personal strings remain anywhere in tracked files**

Run: `git grep -ni "hermes\|/home/jay\|jay\b" -- . ':!docs/superpowers/specs/2026-06-30-repo-showcase-polish-design.md' ':!docs/superpowers/plans/2026-06-30-repo-showcase-polish.md'`
Expected: no output. (The two excluded files are this plan and its design doc, which intentionally describe the leaks that were fixed — they're not the leak themselves.)

- [ ] **Step 2: Confirm all internal README anchors resolve**

Run: `grep -oE '\[.*\]\(#[a-z0-9-]+\)' README.md`
Manually confirm each `#anchor` matches a `## Heading` elsewhere in the file (GitHub slug rules: lowercase, spaces → hyphens, `&` and `?` stripped).

- [ ] **Step 3: Final review commit (if any cleanup needed)**

If steps 1-2 found issues, fix them and commit:
```bash
git add -A
git commit -m "docs: fix remaining issues from final verification pass"
```

If no issues found, no commit needed — this task is verification-only.
