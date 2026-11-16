#!/bin/bash
# Progress statistics. Usage: progress.sh [user]
source "$(dirname "$0")/common.sh"
tracking -v user_name="${1:-}" <<'SQL'
SELECT * FROM v_progress WHERE :'user_name' = '' OR user_name = :'user_name';
SQL
