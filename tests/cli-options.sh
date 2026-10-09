#!/bin/sh
# sql-queryf-codegen is MIT licensed, see /LICENSE.
# Run from the repository root with HHVM, hackfmt, and Composer dependencies available.
set -eu

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT HUP INT TERM

# Keep stdin open with no data: help and errors must finish without reading it.
mkfifo "$scratch/input"
sleep 30 > "$scratch/input" &
producer=$!
trap 'kill "$producer" 2>/dev/null || :; rm -rf "$scratch"' EXIT HUP INT TERM
exec 3< "$scratch/input"

for args in '--to-strng' '--extended --to-string' '--vanilla --extended' \
  '--vanilla --to-string' '--to-string --extended' '--extended --vanilla' \
  '--to-string --vanilla' 'unexpected' '--help --to-strng'; do
  status=0
  timeout 5 hhvm ${HHVM_FLAGS:-} -dhhvm.jit=0 bin/sql-queryf.hack $args <&3 > "$scratch/out" 2> "$scratch/err" || status=$?
  test "$status" -eq 1
  test ! -s "$scratch/out"
  test -s "$scratch/err"
done

for args in '--help' '--help --extended' '--extended --help'; do
  timeout 5 hhvm ${HHVM_FLAGS:-} -dhhvm.jit=0 bin/sql-queryf.hack $args <&3 > "$scratch/out" 2> "$scratch/err"
  test ! -s "$scratch/out"
  grep -q '^Usage:' "$scratch/err"
done

for preset in default vanilla extended to-string; do
  if [ "$preset" = default ]; then
    hhvm ${HHVM_FLAGS:-} -dhhvm.jit=0 bin/sql-queryf.hack < tests/codegen/preamble.in > "$scratch/$preset"
  else
    hhvm ${HHVM_FLAGS:-} -dhhvm.jit=0 bin/sql-queryf.hack "--$preset" < tests/codegen/preamble.in > "$scratch/$preset"
  fi
  test -s "$scratch/$preset"
done
cmp "$scratch/default" "$scratch/vanilla"
! cmp -s "$scratch/vanilla" "$scratch/extended"
! cmp -s "$scratch/vanilla" "$scratch/to-string"
hhvm ${HHVM_FLAGS:-} -dhhvm.jit=0 bin/sql-queryf.hack --vanilla --vanilla < tests/codegen/preamble.in > "$scratch/repeated"
cmp "$scratch/vanilla" "$scratch/repeated"
echo 'CLI option checks passed.'
