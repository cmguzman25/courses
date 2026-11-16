#!/bin/bash
# Compares the output of the user's answer with the solution's output.
# Usage: validate.sh <exercise_code> <answer_file.sql>
# Exits 0 when correct, 1 otherwise. The answer runs in a read-only transaction.
source "$(dirname "$0")/common.sh"
code="$1"; answer="$2"

read -r solution_path ordered < <(tracking -At -F ' ' -c \
  "SELECT solution_path, ordered FROM exercises WHERE code = '$code'")
[ -n "${solution_path:-}" ] || { echo "Exercise '$code' does not exist"; exit 2; }

run_query() {
  PGOPTIONS='-c default_transaction_read_only=on -c statement_timeout=10s' \
    "${PSQL_ADMIN[@]}" -d practice -A -F '|' -P footer=off -f "$1"
}
tmp=$(mktemp -d)
run_query "$PROJECT/$solution_path" > "$tmp/expected.txt"
if ! run_query "$answer" > "$tmp/actual.txt" 2> "$tmp/error.txt"; then
  echo "RESULT: ERROR running the answer"; cat "$tmp/error.txt"; exit 1
fi

if [ "$ordered" != "t" ]; then
  for f in expected actual; do
    { head -1 "$tmp/$f.txt"; tail -n +2 "$tmp/$f.txt" | sort; } > "$tmp/$f.srt"; mv "$tmp/$f.srt" "$tmp/$f.txt"
  done
fi

echo "Expected rows: $(($(wc -l < "$tmp/expected.txt") - 1)) | actual rows: $(($(wc -l < "$tmp/actual.txt") - 1))"
if diff -q "$tmp/expected.txt" "$tmp/actual.txt" > /dev/null; then
  echo "RESULT: CORRECT"; exit 0
fi
echo "RESULT: INCORRECT (diff: < expected, > actual)"
diff "$tmp/expected.txt" "$tmp/actual.txt" | head -40 || true
exit 1
