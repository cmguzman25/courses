#!/bin/bash
# Stores an attempt in the tracking database (creates the user if missing).
# Usage: record.sh <user> <exercise_code> <true|false> <answer_file.sql> [comment]
source "$(dirname "$0")/common.sh"
tracking -v user_name="$1" -v code="$2" -v is_correct="$3" \
         -v submitted="$(cat "$4")" -v comment="${5:-}" <<'SQL'
INSERT INTO users (name) VALUES (:'user_name') ON CONFLICT (name) DO NOTHING;
INSERT INTO attempts (user_id, exercise_code, submitted_sql, is_correct, comment)
SELECT user_id, :'code', :'submitted', :'is_correct'::boolean, NULLIF(:'comment', '')
FROM users WHERE name = :'user_name';
SQL
echo "Attempt recorded: $1 · $2 · correct=$3"
