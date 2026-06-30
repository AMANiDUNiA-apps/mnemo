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

## Why mnemo?

The concrete itch that started this: running Claude Code on a vServer and Claude Desktop on a Mac, expecting them to somehow share context with each other — they don't. Installing Claude Code on two machines doesn't make those two instances aware of each other's state. Every machine, every fresh Claude session, starts from zero: you re-explain your projects, your preferences, your conventions, and where you left off, every time. That's not a personal annoyance — it's a structural gap in how multi-machine agent workflows work today, and most developers running agents on more than one machine hit it.

mnemo's goal is to close that gap: configure your memory layers once, then plug any Claude instance — on any machine — into the same memory, plug-and-play. The agent on your vServer and the one on your desktop should see the same projects, the same accumulated knowledge, the same "where you are right now" — without re-teaching either one from scratch. This repository is the architecture for that (see [Roadmap](#roadmap) for what's actually built today vs. still aspirational — it's early).

Beyond cross-machine continuity, mnemo also addresses the more familiar single-agent problem: structured, layered memory keeps context from growing unbounded (cost, latency) while still giving an agent more than a session's worth of working memory.

The longer-term goal is a **native macOS app** (Vapor backend, SwiftData) that makes this memory system usable end-to-end — open source, MIT licensed. A fully native Swift reimplementation of MinerU (used by RAG Anything for multi-modal parsing) isn't practical right now, so that part of the RAG pipeline stays dependent on the existing Python ecosystem for the time being.

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

**Implementation:** Hybrid — Core skills in shared library (`~/brain-memory-skills/`), OS triggers (cron + inotify), Langfuse tracing.

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

### Prerequisites

- **Note:** This repository contains the architecture specification and is the starting point for the open-source implementation, currently in early development.
- Agent with profiles: `brain-memory-manager`, `brain-user-memory`, `brain-agent-memory`, `brain-session-memory`, `brain-project-memory`, `brain-knowledge-memory`, `brain-longterm-memory`, `brain-sensitivity`
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

> **Public framework, private content.** This repo is the shareable blueprint —
> schema, conventions, and structure. The real, infrastructure-aware brain
> content (filled-in agent profiles, todos) lives in a separate private instance
> repo and overlays onto these paths at runtime. No credentials or infra details
> belong in this public repo.

## Roadmap

- ✅ Architecture spec defined; constituent tools brought up on a test vServer
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
| [Apple Docs Offline Archive](https://github.com/OxADD1/Apple-Developer-Documentation-Offline-Archive) | Offline archive of Apple Developer docs (Markdown/JSON) — feeds the planned "Swift Tutor" feasibility study |
| [Understand-Anything](https://github.com/Egonex-AI/Understand-Anything) | Turns code into an interactive, searchable knowledge graph |
| [Crawl4AI](https://github.com/unclecode/crawl4ai) | LLM-optimized web crawling — candidate ingestion tool for `knowledge-memory/wiki/` or `rag/` |
| [Qdrant](https://github.com/qdrant/qdrant) | Vector database — candidate backing store for `knowledge-memory/rag/` |
| [Chonkie](https://github.com/feyninc/chonkie) | Lightweight chunking library for RAG pipelines — candidate chunking step for `knowledge-memory/rag/` |
| [RAG Anything](https://github.com/HKUDS/RAG-Anything) | Multi-modal RAG pipeline (incl. MinerU) |
| [LightRAG](https://github.com/HKUDS/LightRAG) | Graph-based RAG pipeline |
| [Langfuse](https://github.com/langfuse/langfuse) | LLM observability/tracing |
| [AFFiNE](https://github.com/toeverything/AFFiNE) | Self-hosted, Notion-like workspace — candidate control layer |
| [CLI-Anything](https://github.com/HKUDS/CLI-Anything) | Turns existing software into agent-native CLIs (e.g. Blender, GIMP, LibreOffice) without GUI automation — candidate for driving non-CLI tools in future pipeline steps |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this project.

## License

MIT License — see [LICENSE](LICENSE).

---

**mnemo** — *Memory for machines that think.*
