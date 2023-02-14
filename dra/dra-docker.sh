#!/usr/bin/env bash

ENGINE="${CONTAINER_ENGINE:-docker}"
UID_ARGS=()
if [[ "$ENGINE" == "docker" ]]; then
  UID_ARGS+=( --user )
  UID_ARGS+=( $(id -u):$(id -g) )
fi

TEMP_DIR="$(TMPDIR="$(pwd)" mktemp -d -t dra.XXXXXXXXXX)"
TEMP_DIR_BASENAME="$(basename "$TEMP_DIR")"

function finish {
  rm -rf "$TEMP_DIR"
}
trap finish EXIT

$ENGINE run -i -t --rm \
  "${UID_ARGS[@]}" \
  -v "$TEMP_DIR:/tmp/$TEMP_DIR_BASENAME:rw" \
  -w "/tmp/$TEMP_DIR_BASENAME" \
  ghcr.io/mmguero/dra "$@"

mv "$TEMP_DIR"/* ./ >/dev/null 2>&1 || true
