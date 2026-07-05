# wikirag — composable per-wiki retrieval for `knowledge-memory/wiki-knowledge/`

Many small, independent wikis instead of one monolith. Each wiki gets its own BM25 index
(+ optional dense/vector layer); a "RAG" is just a YAML list of wikis to fuse at query time.
Retrieval quality degrades as a single corpus grows — composing small wikis avoids that
while still letting you query across all of them at once.

Working end-to-end on a 23 GB ARM server, zero GPUs: 1,000+ markdown files indexed in
seconds, hybrid (BM25 + vector) search over dozens of composed wikis.

## Architecture

```
wiki   = a folder of markdown + a per-wiki BM25 index (indexes/<wiki>/bm25 + corpus.json)
       + optional Qdrant collection (same name) for a dense/semantic layer

rag    = composition: rag.yaml -> wikis: [wiki-a, wiki-c, wiki-f]
         query time: BM25 search in each chosen wiki (+ vector search if embedded)
                     -> Reciprocal Rank Fusion (RRF) across all hits
```

**Why RRF instead of merging raw scores:** BM25 scores aren't comparable across separate
indexes (different IDF statistics per corpus), and vector cosine-similarity isn't on the
same scale as BM25 either. RRF only uses *ranks*, so wikis (and search types) stay fully
independent — composing a RAG is never more than editing a YAML list, and no index is ever
rebuilt to compose one.

## Pipeline

```
raw/ (read-only source, e.g. tagged markdown export)
   │  tag/curate (your own process — see thirdwiki-spec.md for one convention)
   ▼
theWikis/<category>/<wiki>/content/   (sorted, read-only copy — build_thirdwiki-style step)
   │
   ▼
indexes/<wiki>/   (BM25, via wikirag.py build)
   │
   ▼
Qdrant collection <wiki>   (optional dense layer, via qdrant_layer.py embed)
```

## Files

| File | Purpose |
|---|---|
| `wikirag.py` | Core: `build <wiki> <source-dir>` (BM25 index) + `query <rag.yaml> "<question>"` (RRF over BM25 only) |
| `qdrant_layer.py` | Dense layer: `embed <wiki>` (NVIDIA free-tier embeddings -> Qdrant) + `hybrid <rag.yaml> "<question>"` (RRF over BM25 + vector ranks) |
| `rebuild_all.py` | Rebuilds every BM25 index from a `theWikis/**/content/` tree in one pass |
| `embed_all.py` | Embeds every not-yet-embedded (or partially-embedded) wiki into Qdrant; resumable |
| `docker-compose.qdrant.yml` | Qdrant vector DB, ARM-native, no GPU required |
| `thirdwiki-spec.md` | One concrete convention for the `raw -> tagged -> sorted` step (folder layout, per-wiki setup files) — a reference, not a requirement; bring your own tagging/sorting process |

## Usage

```bash
pip install bm25s chonkie qdrant-client requests pyyaml   # + your embedding provider's client if not HTTP

# 1) BM25 index per wiki (source stays read-only)
python3 wikirag.py build swiftui /path/to/swiftui-wiki/content

# 2) Compose a RAG = edit a YAML file
cat > rag-swift.yaml <<'EOF'
name: swift-dev
wikis: [swiftui, combine]
EOF

# 3) Query (BM25 only)
python3 wikirag.py query rag-swift.yaml "How do I debounce a publisher?" -k 5
```

### Optional: dense layer (Qdrant + free embeddings)

```bash
cd tools/wikirag && docker compose -f docker-compose.qdrant.yml up -d   # :6333

# Needs NVIDIA_API_KEY (free tier: build.nvidia.com) in the environment or a .env next to
# this script. Swap EMBED_MODEL/provider in qdrant_layer.py for a different embedding API.
python3 qdrant_layer.py embed swiftui
python3 qdrant_layer.py hybrid rag-swift.yaml "How do I debounce a publisher and avoid memory leaks?" -k 5

# Or embed every wiki in one resumable batch (respects the provider's rate limit):
python3 embed_all.py
```

Hybrid search noticeably out-performs BM25-only on semantically-loaded questions (recall
across concepts phrased differently, not just keyword overlap) while staying free — no GPU,
free-tier embeddings, Qdrant runs comfortably on a small ARM box.

### Batch-rebuild from a sorted wiki tree

```bash
export WIKIRAG_THEWIKIS=/path/to/theWikis   # default: ../thirdwiki/theWikis
python3 rebuild_all.py
```

## Design notes

- Indexes are **never** written into source folders — sources stay read-only.
- A wiki that isn't embedded into Qdrant just doesn't contribute to the vector side of a
  hybrid query — no error, it silently falls back to BM25-only for that wiki.
- No daily request quota was found for NVIDIA's free embedding endpoint (only a
  32-40 req/min throttle) — `embed_all.py` paces itself accordingly and retries transient
  5xx errors with backoff, but a stricter provider may need a lower `--rpm`.

## Status

Working: BM25 build/query, RRF composition, Qdrant dense layer + hybrid query, resumable
batch embedding. Not yet built: chonkie's markdown-aware chunking recipe (currently uses the
default recursive chunker), per-wiki `stats.md` generation, a LightRAG-style graph layer on
top of fused results.
