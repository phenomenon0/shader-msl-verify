#!/usr/bin/env bash
# Compile MaterialX-generated MSL shaders (msl/mtlx/). Per-file `-c` only —
# no metallib link, because each generated file defines its own
# VertexMain/FragmentMain entry points that would collide at link time.
#
# Upstream generated-code quirks this gate patches (transparently, before
# compiling):
#   * `#define __METAL__` collides with the compiler's own built-in define.
#   * `#define M_PI ...` appears twice; keep only the first (platform M_PI_F).
#     The match must require a boundary after M_PI — without it the pattern
#     also swallows `#define M_PI_INV`, which pbrlib then can't resolve.
#   * a few unused locals inside pbrlib branches (-Wunused-variable).
set -euo pipefail

SDK="${METAL_SDK:-macosx}"
FLAGS=(-c -Wall -Werror -std=metal3.0 -ffast-math -Wno-unused-variable)
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

count=0
for f in msl/mtlx/*.metal; do
  [ -e "$f" ] || continue
  base="$(basename "$f" .metal)"
  work="$OUT/$base.metal"
  # drop the file's own '#define __METAL__'; keep only the FIRST '#define M_PI'
  awk '
    BEGIN { seen = 0 }
    /^[[:space:]]*#define[[:space:]]+__METAL__([[:space:]]|$)/ { next }
    /^[[:space:]]*#define[[:space:]]+M_PI([[:space:]]|$)/ { if (seen) next; seen = 1 }
    { print }
  ' "$f" > "$work"
  echo "== compile: $f"
  xcrun -sdk "$SDK" metal "${FLAGS[@]}" "$work" -o "$OUT/$base.air"
  count=$((count+1))
done

echo "OK: $count MaterialX MSL shaders compiled (compile-only gate)"
if [[ "$count" -eq 0 ]]; then
  echo "ERROR: no msl/mtlx/*.metal files found" >&2
  exit 1
fi