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
