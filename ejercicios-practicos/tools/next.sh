#!/bin/bash
# Lists a user's pending exercises (the first row is the suggested next one).
# Usage: next.sh <user> [language] [level]
source "$(dirname "$0")/common.sh"
tracking -v user_name="$1" -v language="${2:-}" -v level="${3:-}" <<'SQL'
INSERT INTO users (name) VALUES (:'user_name') ON CONFLICT (name) DO NOTHING;
SELECT code, title, previous_attempts, html_path
FROM v_pending
WHERE user_name = :'user_name'
  AND (:'language' = '' OR language = :'language')
  AND (:'level'    = '' OR level    = :'level')
ORDER BY language, level_order, code;
SQL
