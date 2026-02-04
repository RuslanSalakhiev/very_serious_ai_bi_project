#!/usr/bin/env bash
set -euo pipefail

# Load a SQL file into the Postgres container (Colima on macOS, Podman on Windows).
# Default: data/main_seed.sql (matches dbt sources: schema "main")
#
# Usage:
#   bash scripts/load_seed_to_postgres.sh
#   bash scripts/load_seed_to_postgres.sh data/main_seed.sql
#
# On Windows (Podman):
#   COMPOSE_CMD="podman compose" bash scripts/load_seed_to_postgres.sh
#
# Requirements:
#   - compose up -d (service "db" running). macOS: docker compose (Colima). Windows: podman compose.

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_FILE="${1:-"$PROJECT_ROOT/data/main_seed.sql"}"
COMPOSE_CMD="${COMPOSE_CMD:-docker compose}"

cd "$PROJECT_ROOT"

if [[ ! -f "$SQL_FILE" ]]; then
  echo "SQL file not found: $SQL_FILE" >&2
  exit 1
fi

$COMPOSE_CMD exec -T db bash -lc 'export PGPASSWORD="$POSTGRES_PASSWORD"; psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -v ON_ERROR_STOP=1' < "$SQL_FILE"
