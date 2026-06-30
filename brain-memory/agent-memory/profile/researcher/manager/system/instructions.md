---
sensitivity: INTERNAL
doc_size: S
---
# Instructions — research-manager

[[_all/base-conventions]]
[[_all/sensitivity-handling]]

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
