#!/usr/bin/env bash

# https://github.com/woahbase/alpine-gimp
# https://hub.docker.com/r/woahbase/alpine-gimp

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

mkdir -p "$HOME/.config/GIMP" "$HOME/.fonts"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

docker run -d --rm \
  -v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro \
  -v /dev/shm:/dev/shm \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v /run/dbus:/run/dbus:ro \
  -v /run/udev/data:/run/udev/data:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v /usr/share/xml/iso-codes:/usr/share/xml/iso-codes:ro \
  -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro \
  -v "$HOME"/.config/GIMP:/home/alpine/.config/GIMP \
  -v "$HOME"/.fonts:/home/alpine/.fonts:ro \
  -v "$DOCS_FOLDER":/home/alpine/Documents \
  -e "DISPLAY=$DISPLAY" \
  -e GDK_DPI_SCALE \
  -e GDK_SCALE \
  -e PGID=$(id -g) \
  -e PUID=$(id -u) \
  --device /dev/input \
  --name gimp-$(date -u +%s) \
  woahbase/alpine-gimp:latest \
  --no-splash "$@"
