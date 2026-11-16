#!/bin/bash
# Adds a learning note for a user (creates the user if missing).
# Usage: note.sh <user> <exercise_code|-> <topic> <note>
source "$(dirname "$0")/common.sh"
tracking -v user_name="$1" -v code="$2" -v topic="$3" -v note="$4" <<'SQL'
INSERT INTO users (name) VALUES (:'user_name') ON CONFLICT (name) DO NOTHING;
INSERT INTO learning_notes (user_id, exercise_code, topic, note)
SELECT user_id, NULLIF(:'code', '-'), :'topic', :'note'
FROM users WHERE name = :'user_name';
SQL
echo "Note recorded: $1 · $3"
