#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_FILE="$ROOT_DIR/all/render_sort.c"
OUT_FILE="tmp/librender_sort.so"

if [ ! -f "$SRC_FILE" ]; then
    echo "ERROR: source file not found: $SRC_FILE" >&2
    exit 1
fi

mkdir -p tmp

gcc -shared -fPIC -O3 -Wall -Wextra -o "$OUT_FILE" "$SRC_FILE"

echo "Built: $OUT_FILE"