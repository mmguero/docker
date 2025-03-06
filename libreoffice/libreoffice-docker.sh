#!/usr/bin/env bash

# https://github.com/woahbase/alpine-libreoffice
# https://hub.docker.com/r/woahbase/alpine-libreoffice

ENGINE="${CONTAINER_ENGINE:-docker}"
if [[ "$ENGINE" == "podman" ]]; then
  CONTAINER_PUID=0
  CONTAINER_PGID=0
else
  CONTAINER_PUID=$(id -u)
  CONTAINER_PGID=$(id -g)
fi

DOCS_FOLDER="$(realpath $(pwd))"
if [[ -n "$1" ]]; then
  if [[ -f "$1" ]]; then
    DOCS_FOLDER="$(dirname "$(realpath "$1")")"
    DOC_FILE="/home/alpine/Documents/$(basename "$1")"
    shift
    set -- "$@" "$DOC_FILE"
  elif [[ -d "$1" ]]; then
    DOCS_FOLDER="$(realpath "$1")"
    shift
  fi
fi

mkdir -p "$HOME/.config/libreoffice" "$HOME/.fonts"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

$ENGINE run -d --rm \
  -v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro \
  -v /dev/shm:/dev/shm \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v /run/dbus:/run/dbus:ro \
  -v /run/udev/data:/run/udev/data:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro \
  -v "$HOME"/.config/libreoffice:/home/alpine/.config/libreoffice \
  -v "$HOME"/.fonts:/home/alpine/.fonts:ro \
  -v "$DOCS_FOLDER":/home/alpine/Documents \
  -e "DISPLAY=$DISPLAY" \
  -e GDK_DPI_SCALE \
  -e GDK_SCALE \
  -e PGID=$CONTAINER_PGID \
  -e PUID=$CONTAINER_PUID \
  --device /dev/input \
  --name libreoffice-$(date -u +%s) \
  woahbase/alpine-libreoffice:latest \
  "$@"
