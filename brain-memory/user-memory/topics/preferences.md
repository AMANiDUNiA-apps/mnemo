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
