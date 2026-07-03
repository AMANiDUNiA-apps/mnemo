#!/usr/bin/env bash
# overlay-status.sh — read-only drift report between a live brain-memory tree
# and the public framework skeleton (this repo). Prints, never writes.
#
# Usage: tools/overlay-status.sh [LIVE_ROOT] [FRAMEWORK_CLONE]
#   LIVE_ROOT        default: ~/brain-memory
#   FRAMEWORK_CLONE  default: repo containing this script
set -u
LIVE="${1:-$HOME/brain-memory}"
FW="${2:-$(cd "$(dirname "$0")/.." && pwd)}"
FW_BM="$FW/brain-memory"

[ -d "$LIVE" ]  || { echo "live tree not found: $LIVE" >&2; exit 1; }
[ -d "$FW_BM" ] || { echo "framework skeleton not found: $FW_BM" >&2; exit 1; }

echo "== overlay-status: live=$LIVE  framework=$FW_BM =="

echo
echo "-- 1) Skeleton-Ordner, die im Live-Tree fehlen (framework → live Drift)"
(cd "$FW_BM" && find . -type d ! -path '*/.git*') | while read -r d; do
  [ -d "$LIVE/$d" ] || echo "  fehlt live: ${d#./}"
done

echo
echo "-- 2) Live-Ordner ohne Skeleton-Gegenstück (Kandidaten für Skeleton oder Anomalie)"
(cd "$LIVE" && find . -maxdepth 2 -type d ! -path '*/.git*') | while read -r d; do
  [ -d "$FW_BM/$d" ] || echo "  nicht im Skeleton: ${d#./}"
done

echo
echo "-- 3) Framework-Dateien (index.md / *.example), die live abweichen oder fehlen"
(cd "$FW_BM" && find . -type f \( -name 'index.md' -o -name '*.example' \)) | while read -r f; do
  if [ ! -f "$LIVE/$f" ]; then
    echo "  fehlt live: ${f#./}"
  elif ! diff -q "$FW_BM/$f" "$LIVE/$f" >/dev/null 2>&1; then
    echo "  abweichend: ${f#./}"
  fi
done

echo
echo "-- 4) PUBLIC-getaggte Live-Dateien, die (noch) nicht im Framework-Repo liegen"
grep -rl --include='*.md' -E '^sensitivity: *"?PUBLIC"?' "$LIVE" 2>/dev/null | while read -r f; do
  rel="${f#"$LIVE"/}"
  [ -f "$FW_BM/$rel" ] || echo "  Kandidat: $rel"
done

echo
echo "-- 5) Live-Markdown ohne sensitivity:-Frontmatter (Tag-Pflicht verletzt)"
missing=0
while read -r f; do
  head -20 "$f" | grep -qE '^sensitivity:' || { echo "  ohne Tag: ${f#"$LIVE"/}"; missing=$((missing+1)); [ "$missing" -ge 25 ] && echo "  … (weitere unterdrückt)" && break; }
done < <(find "$LIVE" -name '*.md' -type f)

echo
echo "== Ende Report (read-only) =="
