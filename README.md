# mnemo — LLM Brain Memory Manager

> **A multi-layered memory system for LLM agents** — Distributes and synchronizes information across specialized memory layers so each agent achieves optimal results with minimal context/token consumption.

## Overview

mnemo implements a **6-layer memory architecture** designed for LLM agent ecosystems. Each layer has a distinct purpose, ownership, and access rules — enabling agents to load only their relevant subset via namespaces, tags, and MCP resources.

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER-MEMORY          → User profile, preferences, history   │
├─────────────────────────────────────────────────────────────────┤
│ 2. AGENT-MEMORY         → Skills, MCPs, CLIs, agent configs    │
├─────────────────────────────────────────────────────────────────┤
│ 3. SESSION-MEMORY       → Raw sessions + PageIndex analytics   │
├─────────────────────────────────────────────────────────────────┤
│ 4. PROJECT-MEMORY       → Goals, stack, ADRs, TODOs            │
├─────────────────────────────────────────────────────────────────┤
│ 5. KNOWLEDGE-MEMORY     → Repos, Wiki, RAG (persistent knowledge)│
├─────────────────────────────────────────────────────────────────┤
│ 6. LONGTERM-MEMORY      → Promoted session insights (curated)  │
└─────────────────────────────────────────────────────────────────┘
+ SENSITIVITY-LAYER       → Tag enforcement & privacy policies
```

## Key Features

- **Layer Isolation** — Each layer has clear purpose, ownership & access rules
- **Token Minimization** — Agents load only relevant subsets (tags, namespaces, MCP)
- **Human-Readable** — Markdown primary format, JSON for indexes
- **Plug & Play Vision** — Entire system installable as package
- **Observability** — Langfuse integration for tracing, evaluation, privacy control

## Architecture

### Memory Layers

| Layer | Profile | Responsibility |
|-------|---------|----------------|
| `user-memory` | `brain-user-memory` | User profile, preferences, history |
| `agent-memory` | `brain-agent-memory` | Skills, MCPs, CLIs, agent configs |
| `session-memory` | `brain-session-memory` | Raw sessions, PageIndex analytics |
| `project-memory` | `brain-project-memory` | Goals, stack, ADRs, TODOs |
| `knowledge-memory` | `brain-knowledge-memory` | Repos, Wiki, RAG |
| `longterm-memory` | `brain-longterm-memory` | Promoted insights, patterns |
| `sensitivity-layer` | `brain-sensitivity` | Tags, enforcement, policies |
| **Orchestrator** | **`brain-memory-manager`** | Delegation, audit-log, cross-layer ops |

### Sensitivity Tags (4 Levels)

| Tag | Meaning | LLM Access | Logging |
|-----|---------|------------|---------|
| `[PUBLIC]` | Free to forward, external models OK | ✅ All | ✅ Full |
| `[INTERNAL]` | Local models only, no cloud LLM | ✅ Local only | ✅ Metadata |
| `[SENSITIVE]` | Never in LLM context, structural ref only | ❌ Never | ❌ No payload |
| `[PRIVATE]` | Absolutely local, no logging | ❌ Never | ❌ Nothing |

### Doc-Size Tiering (xs–XL)

| Size | Purpose | ~Tokens |
|------|---------|---------|
| **xS** | System prompts, reference snippets | 50–150 |
| **S** | Quick context, agent briefing | 150–500 |
| **M** | Normal context, standard tasks | 500–2,000 |
| **L** | Detailed context, complex tasks | 2,000–8,000 |
| **XL** | Complete documentation, onboarding | 8,000–32,000 |

## Tools & Services

| Tool | Layer | Purpose |
|------|-------|---------|
| **Gortex** | `knowledge-memory/repo/` | MCP server for code navigation, symbol search |
| **PageIndex** | `session-memory/` | Vectorless RAG for sessions (tree-index + summaries) |
| **LLM-Wiki** | `knowledge-memory/wiki/` | Karpathy-pattern LLM-maintained wiki |
| **Understand-Anything** | `knowledge-memory/repo/` & `wiki/` | Code/doc analysis → ADRs, summaries, dep graphs |
| **LightRAG** | `knowledge-memory/rag/` | Graph-RAG pipeline (incremental + full rebuild) |
| **RAG Anything** | `knowledge-memory/rag/` | Multi-modal RAG (PDF, images, tables, code) |

## Pipeline

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

**Implementation:** Hybrid — Core skills in shared library (`~/system/clis/brain-memory-skills/`), OS triggers (cron + inotify), Langfuse tracing.

## Git Workflow

- Each profile works on its own branch: `ingest/<layer>-<timestamp>`
- `brain-memory-manager` merges `--no-ff` → `main` + tags
- Atomic ingests, full history, rollback capability

## Backup Strategy

- **Restic/Borg** (daily) + **rclone** to Google Drive (5TB, interim)
- **Future:** Syncthing to Home NAS
- **Verification:** Monthly `restic check --read-data-subset=5%` + `rclone check`

## Telemetry

- **Langfuse OTLP** + **JSONL token tracking** (`brain-memory/telemetry/token-usage.jsonl`)
- Tracks: model, provider, thinking mode, input/output tokens, cost, layer accessed, doc-sizes
- Privacy-aware: Sensitivity tags control what gets logged

## Getting Started

> **Note:** This is a specification repository. Implementation lives in the Hermes Agent profiles under `~/.hermes/profiles/brain-*/`.

### Prerequisites

- Hermes Agent with profiles: `brain-memory-manager`, `brain-user-memory`, `brain-agent-memory`, `brain-session-memory`, `brain-project-memory`, `brain-knowledge-memory`, `brain-longterm-memory`, `brain-sensitivity`
- Tools: `gortex`, `pageindex`, `lightrag`, `rag-anything` (as MCP servers)
- Langfuse instance (self-hosted or cloud) for observability

### Folder Structure

```
brain-memory/
├── user-memory/
├── agent-memory/
├── session-memory/
├── project-memory/
├── knowledge-memory/
│   ├── repo/
│   ├── wiki/
│   └── rag/
├── longterm-memory/
└── sensitivity-layer/
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) (to be created).

## License

MIT License — see [LICENSE](LICENSE).

---

**mnemo** — *Memory for machines that think.*