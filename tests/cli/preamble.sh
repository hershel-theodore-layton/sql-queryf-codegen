#!/bin/sh
# Run from the repository root with HHVM and hackfmt on PATH.
set -eu
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

check() {
  # Keep the native autoload database in a directory this test creates.
  hhvm -dhhvm.autoload.enabled=true \
    -dhhvm.autoload.db.path="$work/facts.db" \
    bin/sql-queryf.hack --vanilla < "$work/input" > "$work/output"
  # Verify the real signer's digest against the exact formatted source.
  digest=$(sed -n "s/.*['\"]digest:\([0-9a-f]\{20\}\)['\"].*/\1/p" "$work/output")
  test "${#digest}" = 20
  sed "s/digest:$digest/digest:/" "$work/output" > "$work/unsigned"
  expected=$(sha1sum "$work/unsigned" | cut -c 1-20)
  test "$digest" = "$expected"
  if [ "${2:-}" = one-digest ]; then
    test "$(grep -o 'digest:' "$work/output" | wc -l)" -eq 1
  fi
  printf '%s\n' "PASS $1"
}

printf '%s\n' '/** Example license: keep verbatim. */' 'namespace Example;' "// Pragmas( and 'digest:' are documentation." > "$work/input"
check comments
grep -F '/** Example license: keep verbatim. */' "$work/output" > /dev/null
grep -F "// Pragmas( and 'digest:' are documentation." "$work/output" > /dev/null

printf '%s\n' 'namespace Example;' "const string DOC = \"Pragmas( 'digest:'\";" > "$work/input"
check strings
grep -F "Pragmas( 'digest:'" "$work/output" > /dev/null

for quote in "'" '"'; do
  printf '%s\n' 'namespace Example;' 'use type HTL\Pragma\Pragmas;' \
    "<<file: Pragmas(vec[${quote}PhaLinters${quote}, ${quote}digest:${quote}])>>" > "$work/input"
  check "existing $quote digest" one-digest
done

printf '%s\n' 'namespace Example;' 'use type HTL\Pragma\Pragmas;' \
  "<<file: Pragmas(/* keep attribute comment */ vec['Other', 'keep'])>>" '// Pragmas( stays here' > "$work/input"
check other-pragma
grep -F '/* keep attribute comment */' "$work/output" > /dev/null
grep -F '// Pragmas( stays here' "$work/output" > /dev/null
grep -F "vec['Other', 'keep']" "$work/output" > /dev/null

printf '%s\n' 'namespace Example;' 'use type HTL\Pragma\Pragmas;' \
  "<<file: Pragmas(vec['PhaLinters', 'digest:'])>>" > "$work/input"
printf '%s' '// final comment' >> "$work/input"
check no-final-newline
grep -x 'interface Sql {' "$work/output" > /dev/null
printf '\n' >> "$work/input"
check final-newline
grep -x 'interface Sql {' "$work/output" > /dev/null

: > "$work/input"
check empty-preamble one-digest

printf '%s\n' 'namespace Example;' 'use type HTL\Pragma\Pragmas;' \
  '<<file: Pragmas()>>' > "$work/input"
check empty-pragma one-digest

printf '%s\n' 'namespace Example;' '<<file: Other()>>' > "$work/input"
check unrelated-attribute one-digest
grep -F '<<file: Other()>>' "$work/output" > /dev/null
