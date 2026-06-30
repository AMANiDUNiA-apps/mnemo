---
title: "Research how Hermes manages secrets via Bitwarden"
status: open
priority: high
project: mnemo
created: 2026-06-30
tags: [secrets, bitwarden, hermes, security, germany, gdpr]
---

# Bitwarden Secrets Integration Research

## Context

The mnemo agent-memory design requires a runtime-agnostic secrets management
solution. The Hermes agent framework (running on vServer jayServAmani) has
a Bitwarden integration. This research informs the mnemo secrets boundary design.

## Questions to Answer

1. How does Hermes access Bitwarden secrets at runtime?
   - CLI (`bw get item`)? SDK? Environment injection?
2. Which secret types are managed (API keys, tokens, passwords, SSH keys)?
3. How does the Bitwarden session/unlock flow work in an automated context?
4. What are the GDPR implications for German users storing secrets in Bitwarden?
   - Bitwarden EU servers vs. US servers?
   - Self-hosted Bitwarden option?
5. How can this pattern be adapted for the mnemo runtime-agnostic adapter design?

## Deliverable

A recommendation (M-sized doc) for secrets management in mnemo's agent
infrastructure, covering: preferred approach, GDPR considerations, and
concrete example config for Hermes and OpenCode adapters.

## Output path

`brain-memory/knowledge-memory/wiki/infrastructure/secrets-management.md`
