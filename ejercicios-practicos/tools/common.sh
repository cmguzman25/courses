#!/bin/bash
# Shared settings. Always runs inside the ejercicios-postgres container.
set -euo pipefail
PROJECT=/proyecto
PSQL_ADMIN=(psql -X -q -v ON_ERROR_STOP=1 -U "${POSTGRES_USER:-admin}")
tracking() { "${PSQL_ADMIN[@]}" -d tracking "$@"; }
