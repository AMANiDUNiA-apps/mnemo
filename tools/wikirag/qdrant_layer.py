#!/usr/bin/env python3
"""Optional dense/vector layer behind wikirag.py's BM25 (see README.md).

Ein Qdrant-Collection pro Wiki (gleicher Name wie der BM25-Index), Embeddings via
NVIDIA free-tier (nvidia/llama-nemotron-embed-1b-v2, 2048-dim, 32-40 req/min Budget —
siehe provider-rate-limits). Query-Zeit: BM25-Rang + Qdrant-Rang -> RRF (wie bei der
Wiki-Fusion in wikirag.py — Ränge statt Scores, damit beide Sucharten vergleichbar sind).

Kommandos:
  qdrant_layer.py embed <wiki-name>            # embedded den vorhandenen BM25-Corpus, upsert nach Qdrant
  qdrant_layer.py hybrid <rag.yaml> "<frage>" [-k 5]
"""
import argparse
import json
import os
import sys
import time
from pathlib import Path

import bm25s
import requests
import yaml
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, PointStruct, VectorParams

BASE = Path(__file__).resolve().parent
INDEXES = BASE / "indexes"
NVIDIA_URL = "https://integrate.api.nvidia.com/v1/embeddings"
EMBED_MODEL = os.environ.get("WIKIRAG_EMBED_MODEL", "nvidia/llama-nemotron-embed-1b-v2")
DIM = int(os.environ.get("WIKIRAG_EMBED_DIM", "2048"))
QDRANT_URL = os.environ.get("QDRANT_URL", "http://localhost:6333")


def load_env():
    """Lädt NVIDIA_API_KEY etc. aus einer .env neben dem Skript, falls vorhanden.
    Bereits gesetzte Umgebungsvariablen (z.B. aus der Shell) haben Vorrang."""
    env_file = BASE / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if "=" in line and not line.strip().startswith("#"):
                k, _, v = line.partition("=")
                os.environ.setdefault(k.strip(), v.strip())


def embed_batch(texts: list[str], input_type: str, retries: int = 5) -> list[list[float]]:
    key = os.environ["NVIDIA_API_KEY"]
    for attempt in range(retries):
        try:
            r = requests.post(
                NVIDIA_URL,
                headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
                json={"input": texts, "model": EMBED_MODEL, "input_type": input_type},
                timeout=60,
            )
            r.raise_for_status()
            return [d["embedding"] for d in r.json()["data"]]
        except (requests.exceptions.RequestException,) as e:
            if attempt == retries - 1:
                raise
            wait = 2**attempt * 5  # 5s, 10s, 20s, 40s, 80s — transiente 502/503/Timeouts abfedern
            print(f"\n  ⚠ Embed-Fehler ({e}), retry {attempt + 1}/{retries} in {wait}s…")
            time.sleep(wait)


def embed_wiki(wiki: str, batch_size: int = 8, rpm: int = 30) -> None:
    load_env()
    idx_dir = INDEXES / wiki
    store = json.loads((idx_dir / "corpus.json").read_text())
    corpus, meta = store["corpus"], store["meta"]

    client = QdrantClient(url=QDRANT_URL)
    if client.collection_exists(wiki):
        client.delete_collection(wiki)
    client.create_collection(wiki, vectors_config=VectorParams(size=DIM, distance=Distance.COSINE))

    delay = 60.0 / rpm
    point_id = 0
    for i in range(0, len(corpus), batch_size):
        batch = corpus[i : i + batch_size]
        vectors = embed_batch(batch, input_type="passage")
        points = [
            PointStruct(id=point_id + j, vector=vec, payload=meta[i + j] | {"text": batch[j]})
            for j, vec in enumerate(vectors)
        ]
        client.upsert(wiki, points=points)
        point_id += len(batch)
        print(f"  {wiki}: {point_id}/{len(corpus)} embedded", end="\r")
        time.sleep(delay)
    print(f"\n✓ '{wiki}': {point_id} Vektoren -> Qdrant-Collection '{wiki}'")


def hybrid_query(rag_yaml: str, question: str, k: int) -> None:
    load_env()
    cfg = yaml.safe_load(Path(rag_yaml).read_text())
    wikis = cfg["wikis"]
    client = QdrantClient(url=QDRANT_URL)
    q_vec = embed_batch([question], input_type="query")[0]
    q_tokens = bm25s.tokenize([question], stopwords="en")

    fused: dict[tuple[str, int], float] = {}
    stores = {}
    for w in wikis:
        idx_dir = INDEXES / w
        if not idx_dir.exists():
            sys.exit(f"Index fehlt für Wiki '{w}'")
        store = json.loads((idx_dir / "corpus.json").read_text())
        stores[w] = store

        retriever = bm25s.BM25.load(str(idx_dir / "bm25"))
        results, _ = retriever.retrieve(q_tokens, k=min(k * 4, len(store["corpus"])))
        for rank, doc_id in enumerate(results[0]):
            fused[(w, int(doc_id))] = fused.get((w, int(doc_id)), 0.0) + 1.0 / (60 + rank)

        if client.collection_exists(w):
            hits = client.query_points(w, query=q_vec, limit=min(k * 4, len(store["corpus"]))).points
            for rank, hit in enumerate(hits):
                fused[(w, int(hit.id))] = fused.get((w, int(hit.id)), 0.0) + 1.0 / (60 + rank)

    top = sorted(fused.items(), key=lambda kv: -kv[1])[:k]
    print(f"\n📚 Hybrid-RAG '{Path(rag_yaml).stem}' ({'+'.join(wikis)}) — Frage: {question}\n")
    for (w, doc_id), score in top:
        m = stores[w]["meta"][doc_id]
        snippet = stores[w]["corpus"][doc_id][:220].replace("\n", " ")
        print(f"[{score:.4f}] ({w}) {Path(m['file']).name}")
        print(f"    {snippet}…\n")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("embed")
    e.add_argument("wiki")
    e.add_argument("--rpm", type=int, default=30)
    h = sub.add_parser("hybrid")
    h.add_argument("rag_yaml")
    h.add_argument("question")
    h.add_argument("-k", type=int, default=5)
    a = ap.parse_args()
    if a.cmd == "embed":
        embed_wiki(a.wiki, rpm=a.rpm)
    else:
        hybrid_query(a.rag_yaml, a.question, a.k)
