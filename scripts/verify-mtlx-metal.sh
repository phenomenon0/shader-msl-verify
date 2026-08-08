#!/usr/bin/env bash
# Compile MaterialX-generated MSL shaders (msl/mtlx/). Per-file `-c` only —
# no metallib link, because each generated file defines its own
# VertexMain/FragmentMain entry points that would collide at link time.
set -euo pipefail

SDK="${METAL_SDK:-macosx}"
FLAGS=(-c -Wall -Werror -std=metal3.0 -ffast-math -D__METAL__=1)
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

count=0
for f in msl/mtlx/*.metal; do
  [ -e "$f" ] || continue
  base="$(basename "$f" .metal)"
  echo "== compile: $f"
  xcrun -sdk "$SDK" metal "${FLAGS[@]}" "$f" -o "$OUT/$base.air"
  count=$((count+1))
done

echo "OK: $count MaterialX MSL shaders compiled (compile-only gate)"
if [[ "$count" -eq 0 ]]; then
  echo "ERROR: no msl/mtlx/*.metal files found" >&2
  exit 1
fi