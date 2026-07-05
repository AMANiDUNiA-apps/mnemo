#!/usr/bin/env python3
"""wikirag v0 — Prototyp des mnemo Wiki-RAG (Konzept: wiki-rag-concept.md + thirdwiki.md)

Prinzip: viele kleine Wikis, je EIGENER BM25-Index; ein "RAG" ist nur eine YAML-Liste
von Wikis. Query-Zeit: BM25 je Wiki → RRF-Fusion über Ränge (Scores getrennter Indizes
sind nicht vergleichbar, Ränge schon). 0 Tokens, 0 GPU.

Kommandos:
  wikirag.py build  <wiki-name> <quell-glob-oder-dir> [--tag '#wiki/SwiftUI']
  wikirag.py query  <rag.yaml> "<frage>" [-k 5]

Indizes liegen unter ./indexes/<wiki-name>/ (NIE in den Quell-Ordnern — read-only!).
"""
import argparse, json, re, sys
from pathlib import Path

import bm25s
import yaml
from chonkie import RecursiveChunker

BASE = Path(__file__).resolve().parent
INDEXES = BASE / "indexes"


def collect_files(source: str, tag: str | None) -> list[Path]:
    p = Path(source).expanduser()
    files = sorted(p.rglob("*.md")) if p.is_dir() else sorted(Path().glob(source))
    files = [f for f in files if not f.name.startswith("_")]  # _REPORT.md etc. sind Meta, kein Wissen
    if tag:
        # Wortgrenze: '#wiki/Shaders' darf nicht auch '#wiki/ShadersMetal' matchen
        pat = re.compile(re.escape(tag) + r"(?![\w-])")
        files = [f for f in files if pat.search(f.read_text(errors="ignore")[:3000])]
    return files


def build(wiki: str, source: str, tag: str | None) -> None:
    files = collect_files(source, tag)
    if not files:
        sys.exit(f"keine .md-Dateien gefunden für {source} (tag={tag})")

    # v0: Default-Regeln (Absätze/Sätze). Markdown-Recipe braucht huggingface_hub — v1-Upgrade.
    chunker = RecursiveChunker(chunk_size=512)
    corpus, meta = [], []
    for f in files:
        text = f.read_text(errors="ignore")
        text = re.sub(r"^---\n.*?\n---\n", "", text, flags=re.S)  # Frontmatter raus
        for ch in chunker(text):
            t = ch.text.strip()
            if len(t) < 40:
                continue
            corpus.append(t)
            meta.append({"file": str(f), "start": ch.start_index})

    tokens = bm25s.tokenize(corpus, stopwords="en")
    retriever = bm25s.BM25()
    retriever.index(tokens)

    out = INDEXES / wiki
    out.mkdir(parents=True, exist_ok=True)
    retriever.save(str(out / "bm25"))
    (out / "corpus.json").write_text(json.dumps({"corpus": corpus, "meta": meta}))
    print(f"✓ wiki '{wiki}': {len(files)} Dateien → {len(corpus)} Chunks → {out}")


def query(rag_yaml: str, question: str, k: int) -> None:
    cfg = yaml.safe_load(Path(rag_yaml).read_text())
    wikis = cfg["wikis"]
    q_tokens = bm25s.tokenize([question], stopwords="en")

    # RRF: score = Σ 1/(60 + rang) über alle gewählten Wikis
    fused: dict[tuple[str, int], float] = {}
    stores = {}
    for w in wikis:
        idx_dir = INDEXES / w
        if not idx_dir.exists():
            sys.exit(f"Index fehlt für Wiki '{w}' — erst: wikirag.py build {w} <quelle>")
        retriever = bm25s.BM25.load(str(idx_dir / "bm25"))
        store = json.loads((idx_dir / "corpus.json").read_text())
        stores[w] = store
        results, _ = retriever.retrieve(q_tokens, k=min(k * 4, len(store["corpus"])))
        for rank, doc_id in enumerate(results[0]):
            fused[(w, int(doc_id))] = fused.get((w, int(doc_id)), 0.0) + 1.0 / (60 + rank)

    top = sorted(fused.items(), key=lambda kv: -kv[1])[:k]
    print(f"\n📚 RAG '{Path(rag_yaml).stem}' ({'+'.join(wikis)}) — Frage: {question}\n")
    for (w, doc_id), score in top:
        m = stores[w]["meta"][doc_id]
        snippet = stores[w]["corpus"][doc_id][:220].replace("\n", " ")
        print(f"[{score:.4f}] ({w}) {Path(m['file']).name}")
        print(f"    {snippet}…\n")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    b = sub.add_parser("build")
    b.add_argument("wiki"); b.add_argument("source"); b.add_argument("--tag", default=None)
    q = sub.add_parser("query")
    q.add_argument("rag_yaml"); q.add_argument("question"); q.add_argument("-k", type=int, default=5)
    a = ap.parse_args()
    if a.cmd == "build":
        build(a.wiki, a.source, a.tag)
    else:
        query(a.rag_yaml, a.question, a.k)
