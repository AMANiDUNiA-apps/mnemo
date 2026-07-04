#!/usr/bin/env python3
"""sensitivity_guard.py — technical enforcement for the mnemo sensitivity layer.

The sensitivity tag is normally enforced by *storage location* + convention.
This tool adds a machine gate: it indexes every memory file's tag into a
SQLite db (path -> tag) and answers "may this file go to <audience>?" so a
pipeline can filter/redact BEFORE an LLM call.

Stdlib + PyYAML only. No network, no writes to memory files — read + index.

Commands
  index            (re)build the SQLite index from the live tree
  check PATH...     print tag + policy decision for given files
  guard AUDIENCE    read paths on stdin, emit only the allowed ones on stdout,
                    blocked ones on stderr (the pre-LLM gate)
  audit             untagged / misplaced / restricted-tag report

Audiences (most→least restrictive gate):
  cloud          external / cloud LLM   → PUBLIC only
  public-export  committing to a public repo → PUBLIC only
  local          on-device / local LLM  → PUBLIC + INTERNAL

Policy tiers come from <root>/sensitivity-layer/config.yaml when present,
else the built-in default below.
"""
from __future__ import annotations

import argparse
import os
import sqlite3
import sys
from pathlib import Path

try:
    import yaml
except ImportError:  # pragma: no cover - PyYAML is expected on the instance
    yaml = None

# Restrictiveness order — index = how locked-down the tag is.
TIERS = ["PUBLIC", "INTERNAL", "SENSITIVE", "PRIVATE"]
RANK = {t: i for i, t in enumerate(TIERS)}

# audience -> highest tier still allowed through the gate
AUDIENCE_MAX = {
    "cloud": "PUBLIC",
    "public-export": "PUBLIC",
    "local": "INTERNAL",
}

DEFAULT_ROOT = Path(os.path.expanduser("~/brain-memory"))


def db_path(root: Path) -> Path:
    return root / "sensitivity-layer" / "index.db"


def default_tag(root: Path) -> str:
    """Read default_tag from the layer config; fall back to INTERNAL (fail safe)."""
    cfg = root / "sensitivity-layer" / "config.yaml"
    if yaml and cfg.is_file():
        try:
            data = yaml.safe_load(cfg.read_text()) or {}
            tag = str(data.get("default_tag", "INTERNAL")).upper()
            if tag in RANK:
                return tag
        except Exception:
            pass
    return "INTERNAL"


def read_tag(f: Path):
    """Return (tag_or_None, has_frontmatter). Only the leading YAML block is read."""
    try:
        with f.open("r", encoding="utf-8", errors="replace") as fh:
            first = fh.readline()
            if first.strip() != "---":
                return None, False
            lines = []
            for line in fh:
                if line.strip() == "---":
                    break
                lines.append(line)
    except OSError:
        return None, False
    block = "".join(lines)
    tag = None
    if yaml:
        try:
            data = yaml.safe_load(block) or {}
            if isinstance(data, dict) and data.get("sensitivity"):
                tag = str(data["sensitivity"]).strip().strip('"').strip("'").upper()
        except Exception:
            tag = None
    if tag is None:  # tolerant fallback if YAML choked on a messy block
        for line in block.splitlines():
            if line.lower().startswith("sensitivity:"):
                tag = line.split(":", 1)[1].strip().strip('"').strip("'").upper()
                break
    return (tag if tag in RANK else tag), True


def iter_md(root: Path):
    for p in sorted(root.rglob("*.md")):
        if ".git" in p.parts:
            continue
        yield p


def cmd_index(root: Path, args) -> int:
    dbp = db_path(root)
    dbp.parent.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(dbp)
    con.execute(
        "CREATE TABLE IF NOT EXISTS files ("
        "  path TEXT PRIMARY KEY, tag TEXT, has_frontmatter INTEGER,"
        "  valid_tag INTEGER, mtime REAL)"
    )
    con.execute("DELETE FROM files")
    n = tagged = 0
    for p in iter_md(root):
        rel = str(p.relative_to(root))
        tag, has_fm = read_tag(p)
        valid = 1 if tag in RANK else 0
        if valid:
            tagged += 1
        con.execute(
            "INSERT OR REPLACE INTO files VALUES (?,?,?,?,?)",
            (rel, tag, int(has_fm), valid, p.stat().st_mtime),
        )
        n += 1
    con.commit()
    con.close()
    print(f"indexed {n} files → {dbp}  ({tagged} validly tagged, {n - tagged} not)")
    return 0


def _lookup(root: Path, rel: str):
    """Tag for a path — prefer the db, fall back to reading the file live."""
    dbp = db_path(root)
    if dbp.is_file():
        con = sqlite3.connect(dbp)
        row = con.execute("SELECT tag, valid_tag FROM files WHERE path=?", (rel,)).fetchone()
        con.close()
        if row:
            return row[0], bool(row[1])
    p = root / rel
    if p.is_file():
        tag, _ = read_tag(p)
        return tag, tag in RANK
    return None, False


def cmd_check(root: Path, args) -> int:
    dft = default_tag(root)
    for raw in args.paths:
        p = Path(raw)
        rel = str(p.relative_to(root)) if p.is_absolute() and str(p).startswith(str(root)) else raw
        tag, valid = _lookup(root, rel)
        eff = tag if valid else dft
        note = "" if valid else f"  (untagged → default {dft})"
        gates = " ".join(
            f"{aud}:{'PASS' if RANK[eff] <= RANK[mx] else 'BLOCK'}"
            for aud, mx in AUDIENCE_MAX.items()
        )
        print(f"{rel}\ttag={tag or '-'}{note}\t{gates}")
    return 0


def cmd_guard(root: Path, args) -> int:
    mx = AUDIENCE_MAX[args.audience]
    dft = default_tag(root)
    allowed = blocked = 0
    for line in sys.stdin:
        raw = line.strip()
        if not raw:
            continue
        p = Path(raw)
        rel = str(p.relative_to(root)) if p.is_absolute() and str(p).startswith(str(root)) else raw
        tag, valid = _lookup(root, rel)
        eff = tag if valid else dft  # fail safe: unknown/untagged treated as default (INTERNAL)
        if RANK[eff] <= RANK[mx]:
            print(raw)
            allowed += 1
        else:
            blocked += 1
            reason = f"{tag or 'untagged'}" + ("" if valid else f"→{dft}")
            print(f"BLOCK[{args.audience}] {rel}  ({reason} > {mx})", file=sys.stderr)
    print(
        f"guard {args.audience}: {allowed} allowed, {blocked} blocked",
        file=sys.stderr,
    )
    return 1 if blocked else 0


def cmd_audit(root: Path, args) -> int:
    counts = {t: 0 for t in TIERS}
    untagged, restricted = [], []
    for p in iter_md(root):
        rel = str(p.relative_to(root))
        tag, _ = read_tag(p)
        if tag in RANK:
            counts[tag] += 1
            if RANK[tag] >= RANK["SENSITIVE"]:
                restricted.append((rel, tag))
        else:
            untagged.append(rel)
    print("== sensitivity audit:", root, "==")
    print("tag distribution:", ", ".join(f"{t}={counts[t]}" for t in TIERS))
    print(f"\nuntagged files ({len(untagged)}) — tag-Pflicht verletzt:")
    for rel in untagged[:50]:
        print("  ", rel)
    if len(untagged) > 50:
        print(f"   … +{len(untagged) - 50} more")
    print(f"\nrestricted (SENSITIVE/PRIVATE) files ({len(restricted)}) — never to any LLM:")
    for rel, tag in restricted:
        print(f"   {tag}\t{rel}")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description="mnemo sensitivity-layer enforcement gate")
    ap.add_argument("--root", default=str(DEFAULT_ROOT), help="live brain-memory root")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("index", help="(re)build the SQLite tag index")
    c = sub.add_parser("check", help="show tag + gate decisions for files")
    c.add_argument("paths", nargs="+")
    g = sub.add_parser("guard", help="stdin paths → allowed on stdout, blocked on stderr")
    g.add_argument("audience", choices=sorted(AUDIENCE_MAX))
    sub.add_parser("audit", help="untagged / restricted-tag report")
    args = ap.parse_args()
    root = Path(os.path.expanduser(args.root)).resolve()
    if not root.is_dir():
        print(f"root not found: {root}", file=sys.stderr)
        return 2
    return {
        "index": cmd_index,
        "check": cmd_check,
        "guard": cmd_guard,
        "audit": cmd_audit,
    }[args.cmd](root, args)


if __name__ == "__main__":
    raise SystemExit(main())
