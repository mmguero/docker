#!/usr/bin/env bash

ENGINE="${CONTAINER_ENGINE:-docker}"
if [[ "$ENGINE" == "podman" ]]; then
  CONTAINER_PUID=0
  CONTAINER_PGID=0
else
  CONTAINER_PUID=$(id -u)
  CONTAINER_PGID=$(id -g)
fi

DIR="$(pwd)"

$ENGINE run -i -t --rm \
  -e PUID=$CONTAINER_PUID \
  -e PGID=$CONTAINER_PGID \
  -v "$DIR:$DIR:rw" \
  -w "$DIR" \
  oci.guero.org/yt-dlp "$@"
