#!/usr/bin/env bash
# Export docs/diagrams/*.drawio to SVG (with the editable diagram and icons embedded).
# Requires the draw.io desktop app (https://github.com/jgraph/drawio-desktop/releases).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DRAWIO="${DRAWIO:-}"
if [[ -z "$DRAWIO" ]]; then
  if command -v drawio >/dev/null 2>&1; then
    DRAWIO="drawio"
  elif [[ -x "/Applications/draw.io.app/Contents/MacOS/draw.io" ]]; then
    DRAWIO="/Applications/draw.io.app/Contents/MacOS/draw.io"
  else
    echo "draw.io CLI not found; install draw.io desktop or set DRAWIO=/path/to/drawio" >&2
    exit 1
  fi
fi

for src in "$ROOT"/docs/diagrams/*.drawio; do
  out="${src%.drawio}.svg"
  echo "Exporting $(basename "$src") -> $(basename "$out")"
  "$DRAWIO" --export --format svg --embed-diagram --embed-svg-images --border 10 --output "$out" "$src" >/dev/null 2>&1
done
