---
sensitivity: PUBLIC
doc_size: S
layer: user-memory
---
# User Memory Index

Who the user is and how they want to work — tiered so agents load the smallest
sufficient profile. Real profiles are **private** (never in the public framework).

| File | Size | Description | Status |
|---|---|---|---|
| `profile-xs.md` | xS | Minimal profile (~50–150 tok) | — |
| `profile-s.md` | S | Standard profile (~150–500 tok) | — |
| `profile-m.md` | M | Detailed profile | planned |
| `profile-l.md` / `profile-xl.md` | L/XL | Full profile | planned |
| `topics/preferences.md` | M | Working/tooling preferences | — |
| `topics/projects.md` | S | Tracked projects | planned |
| `topics/history.md` | L | Interaction history | planned |

> Profiles carry `sensitivity: INTERNAL` → they live in the private instance repo,
> not in public. See [[sensitivity-layer/index]].
