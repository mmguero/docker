#!/usr/bin/env bash

set -e
set -o pipefail
set -u

ENGINE="${CONTAINER_ENGINE:-docker}"
POSTGRES_SERVICE="${POSTGRES_SERVICE:-postgres}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"

[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME" && type $ENGINE) > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $ENGINE, $REALPATH and $DIRNAME" >&2
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "${SCRIPT_PATH}" >/dev/null 2>&1

BACKUP_DIR="${SCRIPT_PATH}"/backup
mkdir -p "${BACKUP_DIR}"
BACKUP_TIMESTAMP=$(date +%F_%H%M%S)

for DB in $(docker compose exec -T "${POSTGRES_SERVICE}" psql -h localhost -p 5432 -U "${POSTGRES_USER}" -q -A -t -c "SELECT datname FROM pg_database;" | grep -Pv '^(template\d|postgres)$'); do
    echo -n "Backing up ${DB}... " >&2
    set +e
    docker compose exec -T "${POSTGRES_SERVICE}" pg_dump -U "${POSTGRES_USER}" "${DB}" 2>/dev/null | gzip > "${BACKUP_DIR}/${DB}_${BACKUP_TIMESTAMP}.sql.gz"
    if [[ $? -eq 0 ]]; then
        echo "success ✅" >&2
        ls -1t "${BACKUP_DIR}/${DB}"_*.sql.gz | tail -n +8 | xargs -r rm --
    else
        echo "failed ❌" >&2
        rm -f "${BACKUP_DIR}/${DB}_${BACKUP_TIMESTAMP}.sql.gz"
    fi
    set -e
done

popd >/dev/null 2>&1