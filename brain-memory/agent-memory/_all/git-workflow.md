---
sensitivity: PUBLIC
doc_size: xS
---
# Git Workflow

## Branch Convention

Each profile works on its own branch:
```
ingest/<layer>-<timestamp>
```
Example: `ingest/agent-memory-2026-06-30T14:00`

## Merge

`brain-memory-manager` merges `--no-ff` → `main` + tags each ingest.

```bash
git merge --no-ff ingest/<layer>-<timestamp> -m "ingest(<layer>): <description>"
git tag ingest/<layer>-<timestamp>
```

## Commit Message Convention

```
ingest(<layer>): <short description>
feat(<layer>): <short description>
fix(<layer>): <short description>
docs(<layer>): <short description>
```
