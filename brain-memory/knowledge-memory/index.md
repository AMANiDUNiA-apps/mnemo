---
sensitivity: PUBLIC
doc_size: S
layer: knowledge-memory
---
# Knowledge Memory Index

External knowledge the agents draw on, in three complementary forms.

| Path | Managed by | Description |
|---|---|---|
| `repo-knowledge/` | **Gortex** | Source-code repositories, graph-indexed |
| `wiki-knowledge/` | **LLM-Wiki** (Karpathy pattern) | LLM-maintained knowledge wiki |
| `rag-knowledge/` | **LightRAG** + **RAG-Anything** | Graph-RAG + multimodal indices |

## repo-knowledge/
Per repo: `index.json` (Gortex tree-index), `<name>-xs.md … -xl.md` (tiered exports),
optional `raw/` originals.

| Repo | Note |
|---|---|
| `MGP/` | HKUDS Memory Governance Protocol — evaluated for the sensitivity layer (concepts adopted, protocol not taken as a dependency). |

## wiki-knowledge/
Per topic: `index.md` (entry point), `CLAUDE.md` (maintenance schema),
`<topic>-xs.md … -xl.md` (tiered summaries).

## rag-knowledge/
Per domain: graph index + vector store + query endpoint (backing services, e.g.
LightRAG / RAG-Anything / wikirag, run locally).
