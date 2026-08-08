#!/usr/bin/env bash
# Compile every MSL shader with Apple's Metal compiler (macOS only) and link
# a metallib. Exit nonzero on the first error — shadows a CI gate.
set -euo pipefail

SDK="${METAL_SDK:-macosx}"
FLAGS=(-c -Wall -Werror -std=metal3.0 -ffast-math)
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

air_files=()
count=0
for f in msl/*.metal; do
  base="$(basename "$f" .metal)"
  air="$OUT/$base.air"
  echo "== compile: $f"
  xcrun -sdk "$SDK" metal "${FLAGS[@]}" "$f" -o "$air"
  air_files+=( "$air" )
  count=$((count+1))
done

echo "== link metallib (${#air_files[@]} air) =="
xcrun -sdk "$SDK" metallib "${air_files[@]}" -o "$OUT/shaders.metallib"
echo "OK: $count MSL shaders compiled"
if [[ -n "${ARTIFACT_DIR:-}" ]]; then
  mkdir -p "$ARTIFACT_DIR"
  cp "$OUT/shaders.metallib" "$ARTIFACT_DIR/"
  ls -l "$ARTIFACT_DIR/shaders.metallib"
fi