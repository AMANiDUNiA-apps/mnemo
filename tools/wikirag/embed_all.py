#!/usr/bin/env python3
"""Embedded alle Wikis (außer session-1) für die Qdrant-Dense-Stufe.
Resumable: überspringt Collections, die schon die volle Punktzahl haben.
NVIDIA-Limit ist 32-40 req/min (kein Tagesbudget wie OpenRouter) -> läuft mit --rpm 30
sicher unter dem Limit, dauert bei ~75k Chunks total aber mehrere Stunden.
"""
import json
import sys
from pathlib import Path

from qdrant_client import QdrantClient

sys.path.insert(0, str(Path(__file__).resolve().parent))
from qdrant_layer import INDEXES, QDRANT_URL, embed_wiki  # noqa: E402


def main(rpm: int = 30):
    client = QdrantClient(url=QDRANT_URL)
    for d in sorted(INDEXES.iterdir()):
        # session-memory-Indizes (Konvention "session-*") sind Chat-Verlauf, nicht Wissen —
        # bewusst von der Dense-Stufe ausgenommen.
        if d.name.startswith("session-") or not (d / "corpus.json").exists():
            continue
        n_chunks = len(json.loads((d / "corpus.json").read_text())["corpus"])
        if client.collection_exists(d.name):
            count = client.count(d.name).count
            if count == n_chunks:
                print(f"⏭  {d.name}: schon vollständig ({count}/{n_chunks}), übersprungen")
                continue
        print(f"▶ {d.name}: embedding {n_chunks} Chunks…")
        embed_wiki(d.name, rpm=rpm)


if __name__ == "__main__":
    main()
