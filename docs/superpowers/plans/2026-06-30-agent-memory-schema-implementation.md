# agent-memory Layer Schema — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the full `brain-memory/agent-memory/` folder structure per the approved design spec, with complete content for the `researcher/` category as the reference implementation and stubs for all other categories.

**Architecture:** Flat Markdown files with YAML frontmatter. Shared content lives once in `_all/` and is referenced via `[[wikilink]]` syntax. Profile-specific content lives under `profile/<category>/<profile-name>/`. No runtime code — pure file structure.

**Spec:** `docs/superpowers/specs/2026-06-30-agent-memory-schema-design.md`

**Tech Stack:** bash, git, Markdown

---

## File Map

```
brain-memory/agent-memory/
├── _all/
│   ├── base-conventions.md           CREATE (Task 1)
│   ├── sensitivity-handling.md       CREATE (Task 1)
│   ├── git-workflow.md               CREATE (Task 1)
│   └── skills/.gitkeep               CREATE (Task 1)
├── index.md                          MODIFY (Task 6)
└── profile/
    ├── researcher/
    │   ├── manager/                  CREATE (Task 2)
    │   │   ├── CLAUDE.md
    │   │   ├── projects/.gitkeep
    │   │   ├── todos/
    │   │   │   └── 2026-06-30-bitwarden-secrets-research.md
    │   │   ├── ideas/.gitkeep
    │   │   ├── plans/.gitkeep
    │   │   └── system/
    │   │       ├── soul.md
    │   │       ├── instructions.md
    │   │       ├── rules.md
    │   │       ├── index.md
    │   │       ├── log.md
    │   │       └── skills/.gitkeep
    │   ├── reviewer/                 CREATE (Task 3)
    │   │   ├── CLAUDE.md
    │   │   └── system/{soul,instructions,rules,index,log}.md + skills/.gitkeep
    │   └── default/                  CREATE (Task 4)
    │       ├── CLAUDE.md
    │       └── system/{soul,instructions,rules,index,log}.md + skills/.gitkeep
    ├── assistent/{manager,reviewer}/ CREATE (Task 5)
    ├── designer/{manager,reviewer}/  CREATE (Task 5)
    ├── developer/{manager,reviewer}/ CREATE (Task 5)
    ├── memory-manager/{manager,reviewer}/ CREATE (Task 5)
    └── tutor/{manager,reviewer}/     CREATE (Task 5)
```

---

## Task 1: Create _all/ Shared Foundation

**Files:**
- Create: `brain-memory/agent-memory/_all/base-conventions.md`
- Create: `brain-memory/agent-memory/_all/sensitivity-handling.md`
- Create: `brain-memory/agent-memory/_all/git-workflow.md`
- Create: `brain-memory/agent-memory/_all/skills/.gitkeep`

- [ ] **Step 1: Create base-conventions.md**

```bash
cat > brain-memory/agent-memory/_all/base-conventions.md << 'EOF'
---
sensitivity: PUBLIC
doc_size: S
---
# Base Conventions

## File Format

- All files: Markdown with YAML frontmatter
- Required frontmatter fields: `sensitivity`, `doc_size`
- Dates: ISO 8601 (`YYYY-MM-DD`)

## Doc-Size Tiering

| Size | ~Tokens | Use For |
|---|---|---|
| xS | 50–150 | System prompts, reference snippets |
| S | 150–500 | Quick context, agent briefing |
| M | 500–2,000 | Normal context, standard tasks |
| L | 2,000–8,000 | Detailed context, complex tasks |
| XL | 8,000–32,000 | Complete documentation, onboarding |

## Naming Conventions

- Todo files: `YYYY-MM-DD-<slug>.md`
- Plan files: `YYYY-MM-DD-<slug>.md`
- All slugs: lowercase, hyphens only, no spaces

## Wikilink References

`[[path/to/file]]` references shared content. The runtime adapter resolves
these before injecting context into an agent. For human readers: follow the
path relative to `brain-memory/agent-memory/`.

Example: `[[_all/sensitivity-handling]]` → `_all/sensitivity-handling.md`
EOF
```

- [ ] **Step 2: Create sensitivity-handling.md**

```bash
cat > brain-memory/agent-memory/_all/sensitivity-handling.md << 'EOF'
---
sensitivity: PUBLIC
doc_size: S
---
# Sensitivity Handling

## Tags

| Tag | LLM Access | Logging | Meaning |
|---|---|---|---|
| `[PUBLIC]` | All models | Full | Safe to forward, external models OK |
| `[INTERNAL]` | Local models only | Metadata only | No cloud LLMs |
| `[SENSITIVE]` | Never | No payload | Structural reference only |
| `[PRIVATE]` | Never | Nothing | Absolutely local, no logging |

## Enforcement Rules

- Check `sensitivity` frontmatter BEFORE including any file in LLM context
- `INTERNAL` and above: never send to cloud APIs (Claude, OpenAI, Gemini, etc.)
- Files without a sensitivity tag: treat as `INTERNAL`
- When in doubt: escalate to the next more restrictive level

## Secrets

- API keys, passwords, tokens, credentials: NEVER in the mnemo repo
- Use a professional secrets manager (e.g. Bitwarden) — mandatory in Germany (GDPR)
- Runtime config containing secrets stays local per machine, not version-controlled
- Use `config.yaml.example` in the repo as the template; actual values live locally
EOF
```

- [ ] **Step 3: Create git-workflow.md**

```bash
cat > brain-memory/agent-memory/_all/git-workflow.md << 'EOF'
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
EOF
```

- [ ] **Step 4: Create skills/.gitkeep**

```bash
mkdir -p brain-memory/agent-memory/_all/skills
touch brain-memory/agent-memory/_all/skills/.gitkeep
```

- [ ] **Step 5: Verify structure**

```bash
find brain-memory/agent-memory/_all -type f | sort
```

Expected output:
```
brain-memory/agent-memory/_all/base-conventions.md
brain-memory/agent-memory/_all/git-workflow.md
brain-memory/agent-memory/_all/sensitivity-handling.md
brain-memory/agent-memory/_all/skills/.gitkeep
```

- [ ] **Step 6: Commit**

```bash
git add brain-memory/agent-memory/_all/
git commit -m "feat(agent-memory): add _all/ shared foundation files"
```

---

## Task 2: Scaffold researcher/manager (Reference Implementation)

**Files:** All under `brain-memory/agent-memory/profile/researcher/manager/`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p brain-memory/agent-memory/profile/researcher/manager/system/skills
mkdir -p brain-memory/agent-memory/profile/researcher/manager/projects
mkdir -p brain-memory/agent-memory/profile/researcher/manager/todos
mkdir -p brain-memory/agent-memory/profile/researcher/manager/ideas
mkdir -p brain-memory/agent-memory/profile/researcher/manager/plans
touch brain-memory/agent-memory/profile/researcher/manager/system/skills/.gitkeep
touch brain-memory/agent-memory/profile/researcher/manager/projects/.gitkeep
touch brain-memory/agent-memory/profile/researcher/manager/ideas/.gitkeep
touch brain-memory/agent-memory/profile/researcher/manager/plans/.gitkeep
```

- [ ] **Step 2: Create system/soul.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/manager/system/soul.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# soul — research-manager

I am the Research Manager. I orchestrate the researcher team.

My purpose is routing, delegation, and synthesis — never research itself.
When a request arrives, I identify the right sub-profile, dispatch it,
collect and assemble the results, and route them through the reviewer
before delivering anything.

I think in terms of: what is being asked, who knows this best,
and what shape should the final answer take.
EOF
```

- [ ] **Step 3: Create system/instructions.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/manager/system/instructions.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: S
---
# Instructions — research-manager

[[_all/base-conventions]]

## Routing Logic

| Request topic | Delegate to |
|---|---|
| LLM model comparison, benchmarks, pricing, capabilities | `researcher/llm/<provider>` or `researcher/llm/overall` |
| Food, nutrition, recipes, restaurants | `researcher/food` |
| Anything else (catch-all) | `researcher/default` |

If unsure which specialist fits → delegate to `researcher/default`.
If topic spans multiple domains → delegate to multiple sub-profiles in parallel,
then synthesize results.

## Task Flow

1. Parse the incoming request: topic, scope, depth, output format
2. Select sub-profile(s) using the routing table above
3. Dispatch via `delegate_task` with full context:
   - the original request
   - any relevant background from `project-memory` or `knowledge-memory`
4. Collect results from all dispatched sub-profiles
5. Route combined output through `researcher/reviewer`
6. Return the reviewed, formatted output to the requester

## Output Format

Default (unless caller specifies otherwise):
- Format: Markdown
- Frontmatter: include `sensitivity` tag appropriate to content
- Default sensitivity: `[PUBLIC]` unless content warrants `[INTERNAL]` or higher
EOF
```

- [ ] **Step 4: Create system/rules.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/manager/system/rules.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# Rules — research-manager

[[_all/sensitivity-handling]]

## Hard Constraints

- NEVER perform research directly — always delegate to a sub-profile
- NEVER return output that has not passed through `researcher/reviewer`
- NEVER include `[SENSITIVE]` or `[PRIVATE]` content in output to requesters
- NEVER store API keys, tokens, or credentials in any file in this repo
EOF
```

- [ ] **Step 5: Create system/index.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/manager/system/index.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# System Index — research-manager

| File | Purpose |
|---|---|
| `soul.md` | Persona and identity |
| `instructions.md` | Behavior rules, routing logic, task flow |
| `rules.md` | Hard constraints |
| `skills/` | Profile-specific skills (empty — add as needed) |
| `log.md` | Activity and change log |
EOF
```

- [ ] **Step 6: Create system/log.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/manager/system/log.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# Log — research-manager

| Date | Change | Author |
|---|---|---|
| 2026-06-30 | Profile scaffolded per agent-memory schema design spec | agent-memory-schema-implementation plan |
EOF
```

- [ ] **Step 7: Create CLAUDE.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/manager/CLAUDE.md << 'EOF'
# research-manager

[[_all/base-conventions]]

## Identity
→ `system/soul.md`

## How I work
→ `system/instructions.md`

## Constraints
→ `system/rules.md`

## Skills
→ `system/skills/`

## Current focus
→ `todos/` | `plans/`

## Project context
→ `projects/`

## System overview
→ `system/index.md`
EOF
```

- [ ] **Step 8: Create first todo (Bitwarden secrets research)**

```bash
cat > "brain-memory/agent-memory/profile/researcher/manager/todos/2026-06-30-bitwarden-secrets-research.md" << 'EOF'
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
EOF
```

- [ ] **Step 9: Verify full researcher/manager structure**

```bash
find brain-memory/agent-memory/profile/researcher/manager -type f | sort
```

Expected:
```
brain-memory/agent-memory/profile/researcher/manager/CLAUDE.md
brain-memory/agent-memory/profile/researcher/manager/ideas/.gitkeep
brain-memory/agent-memory/profile/researcher/manager/plans/.gitkeep
brain-memory/agent-memory/profile/researcher/manager/projects/.gitkeep
brain-memory/agent-memory/profile/researcher/manager/system/index.md
brain-memory/agent-memory/profile/researcher/manager/system/instructions.md
brain-memory/agent-memory/profile/researcher/manager/system/log.md
brain-memory/agent-memory/profile/researcher/manager/system/rules.md
brain-memory/agent-memory/profile/researcher/manager/system/skills/.gitkeep
brain-memory/agent-memory/profile/researcher/manager/system/soul.md
brain-memory/agent-memory/profile/researcher/manager/todos/2026-06-30-bitwarden-secrets-research.md
```

- [ ] **Step 10: Commit**

```bash
git add brain-memory/agent-memory/profile/researcher/manager/
git commit -m "feat(agent-memory): scaffold researcher/manager — reference implementation"
```

---

## Task 3: Scaffold researcher/reviewer

**Files:** All under `brain-memory/agent-memory/profile/researcher/reviewer/`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p brain-memory/agent-memory/profile/researcher/reviewer/system/skills
mkdir -p brain-memory/agent-memory/profile/researcher/reviewer/projects
mkdir -p brain-memory/agent-memory/profile/researcher/reviewer/todos
mkdir -p brain-memory/agent-memory/profile/researcher/reviewer/ideas
mkdir -p brain-memory/agent-memory/profile/researcher/reviewer/plans
touch brain-memory/agent-memory/profile/researcher/reviewer/system/skills/.gitkeep
touch brain-memory/agent-memory/profile/researcher/reviewer/projects/.gitkeep
touch brain-memory/agent-memory/profile/researcher/reviewer/todos/.gitkeep
touch brain-memory/agent-memory/profile/researcher/reviewer/ideas/.gitkeep
touch brain-memory/agent-memory/profile/researcher/reviewer/plans/.gitkeep
```

- [ ] **Step 2: Create system/soul.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/reviewer/system/soul.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# soul — research-reviewer

I am the Research Reviewer. I am the quality gate before research output ships.

I do not produce research — I evaluate it. When output arrives from any researcher
sub-profile, I check it for source quality, factual consistency, sensitivity-tag
compliance, and alignment with the original request.

I approve, flag, or reject. Nothing leaves the researcher team without passing me.
EOF
```

- [ ] **Step 3: Create system/instructions.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/reviewer/system/instructions.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: S
---
# Instructions — research-reviewer

[[_all/base-conventions]]
[[_all/sensitivity-handling]]

## Review Checklist

For each piece of research output received:

1. **Source quality** — are claims backed by sources? Are sources credible and dated?
2. **Factual consistency** — does the output contradict itself or known facts?
3. **Request alignment** — does the output actually answer the original question?
4. **Sensitivity compliance** — is the sensitivity tag correct for the content?
   - No `[PUBLIC]`-tagged output containing INTERNAL-level information
5. **Completeness** — are there obvious gaps the requester will need to ask follow-ups for?

## Output

- **APPROVED:** Return the output with a short review note prepended
- **NEEDS_REVISION:** Return to the originating sub-profile with specific feedback
- **REJECTED:** Return to `research-manager` with reason; manager re-routes or escalates

## Format

Prepend a brief review block to approved output:

```markdown
> **Review:** APPROVED — sources verified, sensitivity: PUBLIC, gaps: none.
> — research-reviewer, 2026-06-30
```
EOF
```

- [ ] **Step 4: Create system/rules.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/reviewer/system/rules.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# Rules — research-reviewer

[[_all/sensitivity-handling]]

## Hard Constraints

- NEVER approve output with unsourced factual claims
- NEVER approve output with a sensitivity tag lower than the content warrants
- NEVER modify the research content itself — only return it with a review verdict
- NEVER approve output that does not answer the original research question
EOF
```

- [ ] **Step 5: Create system/index.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/reviewer/system/index.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# System Index — research-reviewer

| File | Purpose |
|---|---|
| `soul.md` | Persona and identity |
| `instructions.md` | Review checklist, verdicts, output format |
| `rules.md` | Hard constraints |
| `skills/` | Profile-specific skills (empty — add as needed) |
| `log.md` | Activity and change log |
EOF
```

- [ ] **Step 6: Create system/log.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/reviewer/system/log.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# Log — research-reviewer

| Date | Change | Author |
|---|---|---|
| 2026-06-30 | Profile scaffolded per agent-memory schema design spec | agent-memory-schema-implementation plan |
EOF
```

- [ ] **Step 7: Create CLAUDE.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/reviewer/CLAUDE.md << 'EOF'
# research-reviewer

[[_all/base-conventions]]

## Identity
→ `system/soul.md`

## How I work
→ `system/instructions.md`

## Constraints
→ `system/rules.md`

## Skills
→ `system/skills/`

## System overview
→ `system/index.md`
EOF
```

- [ ] **Step 8: Commit**

```bash
git add brain-memory/agent-memory/profile/researcher/reviewer/
git commit -m "feat(agent-memory): scaffold researcher/reviewer"
```

---

## Task 4: Scaffold researcher/default

**Files:** All under `brain-memory/agent-memory/profile/researcher/default/`

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p brain-memory/agent-memory/profile/researcher/default/system/skills
mkdir -p brain-memory/agent-memory/profile/researcher/default/projects
mkdir -p brain-memory/agent-memory/profile/researcher/default/todos
mkdir -p brain-memory/agent-memory/profile/researcher/default/ideas
mkdir -p brain-memory/agent-memory/profile/researcher/default/plans
touch brain-memory/agent-memory/profile/researcher/default/system/skills/.gitkeep
touch brain-memory/agent-memory/profile/researcher/default/projects/.gitkeep
touch brain-memory/agent-memory/profile/researcher/default/todos/.gitkeep
touch brain-memory/agent-memory/profile/researcher/default/ideas/.gitkeep
touch brain-memory/agent-memory/profile/researcher/default/plans/.gitkeep
```

- [ ] **Step 2: Create system/soul.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/default/system/soul.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# soul — researcher/default

I am the Generalist Researcher. I handle research requests that don't fit
a specialized sub-profile.

My job is to find, evaluate, and synthesize information across any domain.
I work with primary sources where possible, note what I can't verify,
and deliver clear Markdown output ready for the reviewer.
EOF
```

- [ ] **Step 3: Create system/instructions.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/default/system/instructions.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: S
---
# Instructions — researcher/default

[[_all/base-conventions]]
[[_all/sensitivity-handling]]

## Research Process

1. Read the request carefully: what is actually being asked?
2. Identify what kind of output is needed (factual summary, comparison, deep dive, etc.)
3. Research the topic using available tools (web search, knowledge-memory, crawl4ai, etc.)
4. Cross-check key claims across at least 2 sources
5. Note confidence level for each claim (high/medium/low)
6. Produce output in the requested doc-size tier (default: M)

## Output Format

```markdown
---
sensitivity: PUBLIC
doc_size: M
sources:
  - url: https://...
    accessed: YYYY-MM-DD
---
# [Research Topic]

[Content]

## Sources
[List with dates accessed]
```

## When to Escalate

- Topic turns out to be LLM-specific → inform `research-manager` to re-route to `llm/*`
- Topic turns out to be food-specific → inform `research-manager` to re-route to `food`
- Request requires access to SENSITIVE/PRIVATE data → stop, flag to `research-manager`
EOF
```

- [ ] **Step 4: Create system/rules.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/default/system/rules.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# Rules — researcher/default

[[_all/sensitivity-handling]]

## Hard Constraints

- NEVER fabricate sources or invent citations
- NEVER present unverified claims without flagging confidence level
- NEVER include SENSITIVE or PRIVATE information in output
- NEVER deliver output directly to the requester — always via `research-manager`
EOF
```

- [ ] **Step 5: Create system/index.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/default/system/index.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# System Index — researcher/default

| File | Purpose |
|---|---|
| `soul.md` | Persona and identity |
| `instructions.md` | Research process, output format, escalation rules |
| `rules.md` | Hard constraints |
| `skills/` | Profile-specific skills (empty — add as needed) |
| `log.md` | Activity and change log |
EOF
```

- [ ] **Step 6: Create system/log.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/default/system/log.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: xS
---
# Log — researcher/default

| Date | Change | Author |
|---|---|---|
| 2026-06-30 | Profile scaffolded per agent-memory schema design spec | agent-memory-schema-implementation plan |
EOF
```

- [ ] **Step 7: Create CLAUDE.md**

```bash
cat > brain-memory/agent-memory/profile/researcher/default/CLAUDE.md << 'EOF'
# researcher/default

[[_all/base-conventions]]

## Identity
→ `system/soul.md`

## How I work
→ `system/instructions.md`

## Constraints
→ `system/rules.md`

## Skills
→ `system/skills/`

## Current focus
→ `todos/` | `plans/`

## System overview
→ `system/index.md`
EOF
```

- [ ] **Step 8: Commit**

```bash
git add brain-memory/agent-memory/profile/researcher/default/
git commit -m "feat(agent-memory): scaffold researcher/default"
```

---

## Task 5: Create manager+reviewer Stubs for Remaining Categories

> **Note for agentic executors:** The bash heredocs below mix variable expansion (`$category`) and backtick characters (for markdown code formatting). If using raw bash, quote the heredoc marker (`<< 'EOF'`) for any section without variable substitution, and use a separate `sed` pass for variable names. **Preferred alternative:** use the Write tool directly with the exact content specified — avoids all shell quoting issues.

Create lightweight manager and reviewer stubs for: `assistent`, `designer`, `developer`, `memory-manager`, `tutor`.

These use a minimal soul.md adapted per role; full instructions will be written when each profile is actively worked on.

- [ ] **Step 1: Create all directory structures**

```bash
for category in assistent designer developer memory-manager tutor; do
  for role in manager reviewer; do
    mkdir -p "brain-memory/agent-memory/profile/$category/$role/system/skills"
    mkdir -p "brain-memory/agent-memory/profile/$category/$role/projects"
    mkdir -p "brain-memory/agent-memory/profile/$category/$role/todos"
    mkdir -p "brain-memory/agent-memory/profile/$category/$role/ideas"
    mkdir -p "brain-memory/agent-memory/profile/$category/$role/plans"
    touch "brain-memory/agent-memory/profile/$category/$role/system/skills/.gitkeep"
    touch "brain-memory/agent-memory/profile/$category/$role/projects/.gitkeep"
    touch "brain-memory/agent-memory/profile/$category/$role/todos/.gitkeep"
    touch "brain-memory/agent-memory/profile/$category/$role/ideas/.gitkeep"
    touch "brain-memory/agent-memory/profile/$category/$role/plans/.gitkeep"
  done
done
```

- [ ] **Step 2: Create CLAUDE.md stubs (identical template, adapt name only)**

```bash
for category in assistent designer developer memory-manager tutor; do
  for role in manager reviewer; do
    cat > "brain-memory/agent-memory/profile/$category/$role/CLAUDE.md" << EOF
# $category/$role

[[_all/base-conventions]]

## Identity
→ \`system/soul.md\`

## How I work
→ \`system/instructions.md\`

## Constraints
→ \`system/rules.md\`

## Skills
→ \`system/skills/\`

## Current focus
→ \`todos/\` | \`plans/\`

## System overview
→ \`system/index.md\`
EOF
  done
done
```

- [ ] **Step 3: Create soul.md stubs per role type**

Manager soul stub:
```bash
for category in assistent designer developer memory-manager tutor; do
cat > "brain-memory/agent-memory/profile/$category/manager/system/soul.md" << EOF
---
sensitivity: INTERNAL
doc_size: xS
---
# soul — $category/manager

I orchestrate the $category team. I route incoming requests to the right
sub-profile, delegate work via \`delegate_task\`, and route all output
through \`$category/reviewer\` before delivering results.

I do not do $category work directly.
EOF
done
```

Reviewer soul stub:
```bash
for category in assistent designer developer memory-manager tutor; do
cat > "brain-memory/agent-memory/profile/$category/reviewer/system/soul.md" << EOF
---
sensitivity: INTERNAL
doc_size: xS
---
# soul — $category/reviewer

I am the quality gate for the $category team. Output from any $category
sub-profile passes through me before being delivered. I check for quality,
consistency, and sensitivity-tag compliance. I approve, flag, or reject.
EOF
done
```

- [ ] **Step 4: Create minimal instructions.md stubs**

```bash
for category in assistent designer developer memory-manager tutor; do
  for role in manager reviewer; do
    cat > "brain-memory/agent-memory/profile/$category/$role/system/instructions.md" << EOF
---
sensitivity: INTERNAL
doc_size: xS
---
# Instructions — $category/$role

[[_all/base-conventions]]

> **TODO:** Write full instructions when this profile is actively developed.
> Use \`researcher/manager/system/instructions.md\` as the reference template.
EOF
  done
done
```

- [ ] **Step 5: Create minimal rules.md stubs**

```bash
for category in assistent designer developer memory-manager tutor; do
  for role in manager reviewer; do
    cat > "brain-memory/agent-memory/profile/$category/$role/system/rules.md" << EOF
---
sensitivity: INTERNAL
doc_size: xS
---
# Rules — $category/$role

[[_all/sensitivity-handling]]

> **TODO:** Write specific rules when this profile is actively developed.
> Until then, \`_all/sensitivity-handling\` constraints apply in full.
EOF
  done
done
```

- [ ] **Step 6: Create index.md and log.md stubs**

```bash
for category in assistent designer developer memory-manager tutor; do
  for role in manager reviewer; do
    cat > "brain-memory/agent-memory/profile/$category/$role/system/index.md" << EOF
---
sensitivity: INTERNAL
doc_size: xS
---
# System Index — $category/$role

| File | Purpose |
|---|---|
| \`soul.md\` | Persona and identity |
| \`instructions.md\` | Behavior rules (stub — expand when profile is active) |
| \`rules.md\` | Hard constraints |
| \`skills/\` | Profile-specific skills |
| \`log.md\` | Activity and change log |
EOF
    cat > "brain-memory/agent-memory/profile/$category/$role/system/log.md" << EOF
---
sensitivity: INTERNAL
doc_size: xS
---
# Log — $category/$role

| Date | Change | Author |
|---|---|---|
| 2026-06-30 | Stub scaffolded per agent-memory schema design spec | agent-memory-schema-implementation plan |
EOF
  done
done
```

- [ ] **Step 7: Verify all stubs were created**

```bash
find brain-memory/agent-memory/profile -maxdepth 2 -name "CLAUDE.md" | sort
```

Expected (all 12 new manager/reviewer profiles, plus the 3 researcher ones from Tasks 2-4):
```
brain-memory/agent-memory/profile/assistent/manager/CLAUDE.md
brain-memory/agent-memory/profile/assistent/reviewer/CLAUDE.md
brain-memory/agent-memory/profile/designer/manager/CLAUDE.md
brain-memory/agent-memory/profile/designer/reviewer/CLAUDE.md
brain-memory/agent-memory/profile/developer/manager/CLAUDE.md
brain-memory/agent-memory/profile/developer/reviewer/CLAUDE.md
brain-memory/agent-memory/profile/memory-manager/manager/CLAUDE.md
brain-memory/agent-memory/profile/memory-manager/reviewer/CLAUDE.md
brain-memory/agent-memory/profile/researcher/default/CLAUDE.md
brain-memory/agent-memory/profile/researcher/manager/CLAUDE.md
brain-memory/agent-memory/profile/researcher/reviewer/CLAUDE.md
brain-memory/agent-memory/profile/tutor/manager/CLAUDE.md
brain-memory/agent-memory/profile/tutor/reviewer/CLAUDE.md
```

- [ ] **Step 8: Commit**

```bash
git add brain-memory/agent-memory/profile/assistent/
git add brain-memory/agent-memory/profile/designer/
git add brain-memory/agent-memory/profile/developer/
git add brain-memory/agent-memory/profile/memory-manager/
git add brain-memory/agent-memory/profile/tutor/
git commit -m "feat(agent-memory): add manager+reviewer stubs for all categories"
```

---

## Task 6: Update agent-memory/index.md

**Files:**
- Modify: `brain-memory/agent-memory/index.md`

- [ ] **Step 1: Replace index.md with the full structure overview**

```bash
cat > brain-memory/agent-memory/index.md << 'EOF'
---
sensitivity: INTERNAL
doc_size: S
---
# Agent Memory Index

Overview of all profiles in `brain-memory/agent-memory/profile/`.

## Profile Categories

| Category | Profiles | Status |
|---|---|---|
| `researcher/` | manager, reviewer, default, food, llm/{google,nvidia,overall,owl-alpha} | 🟢 manager/reviewer/default scaffolded |
| `assistent/` | manager, reviewer, cleaner, tagger | 🟡 manager/reviewer stubbed |
| `developer/` | manager, reviewer, swift-developer, system-developer | 🟡 manager/reviewer stubbed |
| `designer/` | manager, reviewer | 🟡 stubbed |
| `memory-manager/` | manager, reviewer, brain-memory-manager, knowledge-memory-manager | 🟡 manager/reviewer stubbed |
| `tutor/` | manager, reviewer, swift-tutor | 🟡 manager/reviewer stubbed |

## Shared Content

| Path | Purpose |
|---|---|
| `_all/base-conventions.md` | Universal file format, naming, wikilink conventions |
| `_all/sensitivity-handling.md` | Sensitivity tag enforcement rules |
| `_all/git-workflow.md` | Branch and merge conventions |
| `_all/skills/` | Skills shared across profiles |

## Role Conventions

| Role | Folder | Responsibility |
|---|---|---|
| Manager | `<category>/manager/` | Dispatcher — routes, delegates, synthesizes. No direct execution. |
| Reviewer | `<category>/reviewer/` | Quality gate — approves output before it leaves the category. |
| Default | `<category>/default/` | Generalist catch-all executor for the category. |
| Specific | `<category>/<name>/` | Specialized executor for a defined domain. |

## Per-Profile Structure

Every profile folder:
```
<profile>/
├── CLAUDE.md          ← lean entry point with [[wikilink]] references
├── projects/          ← filtered context from project-memory
├── todos/             ← open tasks (one .md per todo, YAML frontmatter)
├── ideas/             ← improvement/research ideas backlog
├── plans/             ← active operational plans (living documents)
└── system/
    ├── soul.md
    ├── instructions.md
    ├── rules.md
    ├── skills/
    ├── index.md
    └── log.md
```

See `docs/superpowers/specs/2026-06-30-agent-memory-schema-design.md` for the full spec.
EOF
```

- [ ] **Step 2: Commit**

```bash
git add brain-memory/agent-memory/index.md
git commit -m "docs(agent-memory): update index with full profile structure and status"
```

---

## Task 7: Sync to vServer

- [ ] **Step 1: Push all commits**

```bash
git push origin main
```

- [ ] **Step 2: Pull on vServer**

```bash
ssh jay@152.53.155.164 "cd ~/github/loadedrepos/mnemo && git pull --ff-only origin main && echo 'Sync OK' && find brain-memory/agent-memory -name 'CLAUDE.md' | wc -l"
```

Expected: `Sync OK` and count ≥ 13 CLAUDE.md files.

- [ ] **Step 3: Done**

The `researcher/manager/` profile is the reference implementation. All other profiles follow the same structure — add content to `system/` files and `todos/` as each profile is actively developed.

**Next sub-project:** C (Orchestration / runtime adapter for Hermes + OpenCode).
