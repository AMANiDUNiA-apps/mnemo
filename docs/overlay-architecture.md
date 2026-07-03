# Overlay Architecture — Two-Repo Privacy Model

> Status: v0.2 draft (2026-07-03). This is the contract for how a mnemo
> instance assembles from a public framework and a private content repo.

## The three places

| Place | What it is | Git? |
|---|---|---|
| **Framework repo** (public, e.g. `amaniagent/mnemo`) | The skeleton: 8-layer folder structure, `index.md` schemas, `*.example` configs, shared `_all/` conventions, spec, tools | yes, public |
| **Content repo** (private, e.g. `<you>/mnemo-brain-memory-intern`) | The full mirror of your live tree: real profiles, plans, sessions, user memory | yes, private |
| **Live tree** (`~/brain-memory`) | The assembled view agents actually read and write. Deliberately **not** a git repo — the two repos above are its source and its backup | no |

```
   framework repo (public)          content repo (private)
   skeleton + conventions           full live mirror
          │                                ▲
          │ pull skeleton/convention       │ hourly one-way sync
          │ updates into live (manual,     │ (sync script + cron:
          │ drift-check assisted)          │  mirror → commit → push)
          ▼                                │
              live tree  ~/brain-memory ───┘
              (agents read/write here)
```

## Ownership rules

1. **Agents write to the live tree only.** Never directly into either clone.
2. **The content repo owns everything in the live tree.** The hourly sync
   mirrors the whole tree (including framework files — harmless duplication,
   it is the disaster-recovery copy).
3. **The framework repo owns structure and conventions**: folder layout,
   `.gitkeep` markers, `index.md` schema files, `*.example` configs, tools,
   and any file tagged `sensitivity: PUBLIC`.
4. **The storage location enforces the sensitivity tag** (see
   `brain-memory/sensitivity-layer/`):
   - `PUBLIC` → may live in the framework repo
   - `INTERNAL` / `SENSITIVE` → private repo or local only, never public
   - `PRIVATE` → local only (private repo only with explicit per-file approval)

## Flows

### live → content repo (automated, hourly)
A cron'd sync script mirrors the live tree into the private clone, commits and
pushes. This is the backup and the multi-device distribution channel. One-way:
live wins, deletions propagate.

### framework repo → live (manual, drift-check assisted)
Framework evolution (new conventions, schema changes, tools) is committed in
the framework repo first, then pulled into the live tree. Run
`tools/overlay-status.sh` to see what differs.

### live → framework repo (curated, deliberate)
When a convention matures in the live instance (e.g. a validator, a build
guide), tag it `sensitivity: PUBLIC` and copy it into the framework repo in a
reviewed commit. The drift check lists `PUBLIC`-tagged files that are not in
the framework repo yet.

## Lifecycle fields (optional, v0.2)

Inspired by the lifecycle semantics of
[MGP — Memory Governance Protocol](https://github.com/HKUDS/MGP), memory files
may carry:

```yaml
status: active        # active | expired | superseded | revoked
supersedes: "<path-or-id of the memory this replaces>"
```

Superseded/revoked files stay on disk (git history is the audit trail) but
agents must skip them when assembling context.

## Why not one repo with branches?

Branches do not give privacy in a public repository — every branch is public.
The repo boundary is the privacy boundary; that is the whole point of the
two-repo split.
