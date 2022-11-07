#!/usr/bin/env bash

ENGINE="${CONTAINER_ENGINE:-docker}"
if [[ "$ENGINE" == "podman" ]]; then
  CONTAINER_PUID=0
  CONTAINER_PGID=0
else
  CONTAINER_PUID=$(id -u)
  CONTAINER_PGID=$(id -g)
fi

TEMP_DIR=$(mktemp -d -t dra.XXXXXXXXXX)

function finish {
  rm -rf "$TEMP_DIR"
}
trap finish EXIT

$ENGINE run -i -t --rm \
  -e PUID=$CONTAINER_PUID \
  -e PGID=$CONTAINER_PGID \
  -v "$TEMP_DIR:$TEMP_DIR:rw" \
  -w "$TEMP_DIR" \
  ghcr.io/mmguero/dra "$@"

mv "$TEMP_DIR"/* ./ >/dev/null 2>&1 || true
