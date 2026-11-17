#!/usr/bin/env bash
# Creates (or recreates from scratch) your own copy of the shop database: shop_<your-name>.
# WARNING: if the database already exists, everything you changed in it is lost.
set -euo pipefail

name="${1:-}"
if [[ ! "$name" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "Usage: bash /curso/scripts/reset-db.sh <your-name>   (lowercase, no spaces)" >&2
  exit 1
fi

db="shop_${name}"
init_dir="/curso/docker/postgres/init"

echo "Creating database ${db}..."
dropdb --if-exists --force "$db"
createdb "$db"
psql -q -v ON_ERROR_STOP=1 -d "$db" -f "$init_dir/01_schema.sql" -f "$init_dir/02_data.sql" > /dev/null
echo "Database ${db} is ready."
