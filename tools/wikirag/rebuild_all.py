#!/usr/bin/env python3
"""Baut alle Indizes aus theWikis/<wiki>/content/ (nicht mehr direkt aus raw/ + --tag).
Schließt die Pipeline: raw (read-only) -> einsortiert (thirdwiki/theWikis) -> indexiert.
Index-Name = Wiki-Ordnername, lowercase, Leerzeichen/'&' -> '-'.
"""
import os
import re
import subprocess
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
# Wurzel des einsortierten Wiki-Baums (thirdwiki-Spec: theWikis/<kategorie>/<wiki>/content/).
# Default: Geschwister-Ordner "thirdwiki" neben diesem Tools-Checkout — überschreibbar per Env.
THEWIKIS = Path(os.environ.get("WIKIRAG_THEWIKIS", BASE.parent.parent / "thirdwiki" / "theWikis"))


def slug(name: str) -> str:
    s = name.lower().replace("&", "and")
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s


def main():
    if not THEWIKIS.exists():
        sys.exit(f"Wiki-Baum nicht gefunden: {THEWIKIS}\n(WIKIRAG_THEWIKIS env var setzen, falls anderswo)")
    for content_dir in sorted(THEWIKIS.rglob("content")):
        wiki_dir = content_dir.parent
        index_name = slug(wiki_dir.name)
        print(f"→ build {index_name}  (aus {content_dir})")
        subprocess.run(
            [sys.executable, str(BASE / "wikirag.py"), "build", index_name, str(content_dir)],
            check=True,
        )


if __name__ == "__main__":
    main()
