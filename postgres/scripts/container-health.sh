#!/usr/bin/env bash

set -euo pipefail

# check if postgres is ready and responding
pg_isready -d "${POSTGRES_DB}" -U "${POSTGRES_USER}" >/dev/null 2>&1 || exit 1
