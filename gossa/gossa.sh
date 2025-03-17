#!/usr/bin/env bash

export UID=${PUID:-$DEFAULT_UID}
export GID=${PGID:-$DEFAULT_GID}

/gossa \
    -h ${HOST:-0.0.0.0} \
    -p ${PORT:-8001} \
    -k=${SKIP_HIDDEN_FILES:-true} \
    -ro=${READONLY:-false} \
    --symlinks=${FOLLOW_SYMLINKS:-false} \
    --prefix="${PREFIX:-/}" \
    --verb=${VERBOSE:-false} \
    "${DATADIR:-/shared}"
