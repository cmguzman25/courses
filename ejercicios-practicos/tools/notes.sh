#!/bin/bash
# Lists a user's learning notes, oldest first. Usage: notes.sh <user>
source "$(dirname "$0")/common.sh"
tracking -v user_name="$1" <<'SQL'
SELECT n.created_at::date AS day, coalesce(n.exercise_code, '-') AS exercise, n.topic, n.note
FROM learning_notes n
JOIN users u ON u.user_id = n.user_id
WHERE u.name = :'user_name'
ORDER BY n.created_at, n.note_id;
SQL
