# mnemo — Repo Showcase Polish (Design)

**Date:** 2026-06-30
**Purpose:** Prepare the mnemo repo as a public showcase project for a Claude MAX (6-month) application — without adding new functionality, only cleaning up and strengthening presentation, consistency, and credit/attribution.

## Context

mnemo is currently a spec + folder-skeleton repo (no implementation code yet) for a 6-layer LLM memory architecture. It's public on GitHub (`amaniagent/mnemo`). The owner wants to use it as a portfolio/showcase piece. A review of the repo surfaced:

1. A real privacy leak: `brain-memory/user-memory/topics/preferences.md` contains the author's actual personal infrastructure preferences (tooling, VPN/mesh setup, backup strategy) committed to a public repo, despite being tagged `sensitivity: INTERNAL` — undermining the very system the repo describes.
2. Private machine paths leaked in README/CONTRIBUTING/spec (`/home/jay/system/files/...`, `~/.hermes/profiles/...`).
3. References to "Hermes Agent," a private/unreleased agent runtime, presented as if required — implies vendor lock-in to a tool nobody else can access.
4. The spec file (`brain-memory-manager-spec.md`) is mixed German/English while README/CONTRIBUTING are English-only; metadata date is stale.
5. `index.md` files in skeleton folders reference template files that don't exist yet, with no "planned" indicator.
6. No credit/attribution for the third-party OSS tools and patterns mnemo composes (it's an assembly of existing tools, not built from scratch).
7. No motivation ("why"), roadmap, or visual-future-direction context in the README — a portfolio reviewer has no sense of where this is headed.

## Goals

- Remove all real personal/private data and machine-specific paths from tracked files.
- Make the repo runtime-agnostic in its language (no "Hermes Agent" required to use the spec).
- Make language usage consistent: README, CONTRIBUTING, and the spec are all English.
- Add a "Why" section explaining the larger vision: a native macOS app (Vapor backend, SwiftData) built on this memory architecture, open source under MIT. Full native Swift reimplementation of MinerU (from RAG Anything) isn't currently practical, so that part of the RAG pipeline stays dependent on the existing Python ecosystem.
- Add a Roadmap section reflecting actual current status:
  - Done: architecture spec defined, constituent tools brought up on a test vServer
  - In progress: implementation tests of individual layers/tools
  - Next: a "Swift Tutor" feasibility study — feed mnemo Swift tutorials/docs, have it generate tutorials — first building block toward **thirdwiki** (fillable, navigable knowledge bases that strengthen human-AI bonding)
  - Next: evaluate AFFiNE (self-hosted, Notion-like, open source) as a control layer to drive mnemo's tools from a UI — tool selection still open
  - Future: native macOS app (Vapor + SwiftData)
- Add a Credits/Acknowledgments section linking and one-lining every third-party tool mnemo currently composes, since mnemo assembles rather than reimplements these:
  - Gortex, PageIndex, Karpathy's LLM-Wiki pattern, Apple Developer Docs Offline Archive, Understand-Anything, Crawl4AI, Qdrant, Chonkie, RAG Anything, LightRAG, Langfuse, AFFiNE
- Bring skeleton `index.md` files in line with what actually exists, marking not-yet-created template files as planned rather than implying they're already there.
- Add minimal `.github/ISSUE_TEMPLATE/` (bug report, spec clarification) matching the CONTRIBUTING workflow.
- Add a table of contents and status/license badges to the README given its length.

## Non-goals

- No new code/implementation (no actual layer logic, no MCP servers, no scripts).
- No connecting to the user's vServer or any live infrastructure — that's a separate, later task.
- No deep evaluation of AFFiNE vs. AppFlowy vs. other tools — mentioned as a roadmap direction only, decision deferred.
- No restructuring of the 6-layer architecture itself — this is presentation/doc work only.

## Scope of changes (by file)

| File | Change |
|------|--------|
| `README.md` | Add ToC, badges, "Why" section, Roadmap section, Credits section; remove Hermes Agent references → generic agent runtime language; remove private paths |
| `CONTRIBUTING.md` | Remove Hermes Agent / private path references; generalize "Development Setup" section |
| `brain-memory-manager-spec.md` | Translate fully to English; update "Last Updated" date; remove Hermes/private path references |
| `brain-memory/user-memory/topics/preferences.md` | Replace real personal content with clearly-labeled generic example content (placeholders, not real data) |
| `brain-memory/*/index.md` (agent-memory, user-memory, etc.) | Mark template-referenced files that don't yet exist as "(planned)" instead of presenting them as present |
| `.github/ISSUE_TEMPLATE/bug_report.md`, `spec_clarification.md` | New, minimal, matching CONTRIBUTING workflow |

## Testing/Verification

Doc-only change — verification is manual review:
- Grep repo for leaked personal paths/strings (`jay`, `/home/`, `.hermes`) to confirm none remain in tracked files.
- Confirm spec file has no German text remaining outside of intentional bilingual examples (none planned).
- Confirm all internal markdown links (ToC, credits) resolve.
