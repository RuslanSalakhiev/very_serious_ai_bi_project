#!/usr/bin/env bash
set -euo pipefail

# Convenience wrapper to generate test data in Postgres using the Python script.
# Uses .env (PGHOST/PGPORT/PGUSER/PGPASSWORD/PGDATABASE) and assumes Postgres
# из docker-compose / Podman доступен на host:port.
#
# Usage:
#   bash scripts/load_seed_to_postgres.sh
#   PYTHON_BIN=python3 bash scripts/load_seed_to_postgres.sh
#
# Требования:
#   - Активированное venv с установленными зависимостями (`pip install -r scripts/requirements.txt`)
#   - Запущен Postgres: macOS (Colima) — `docker compose up -d`, Windows (Podman) — `podman compose up -d`

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

PYTHON_BIN="${PYTHON_BIN:-python}"
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="${PYTHON_BIN:-python3}"
fi

"$PYTHON_BIN" scripts/generate_test_data.py "$@"
