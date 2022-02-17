#!/usr/bin/env bash

DIR="$(pwd)"

docker run -i -t --rm \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -v "$DIR:$DIR:rw" \
  -w "$DIR" \
  ghcr.io/mmguero/yt-dlp "$@"
