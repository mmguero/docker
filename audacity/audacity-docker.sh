#!/usr/bin/env bash

  mkdir -p "$HOME"/.audacity-data \
           "$HOME"/.audacity-file
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

  DOCS_FOLDER="$(realpath $(pwd))"
  if [[ -n "$1" ]]; then
    if [[ -f "$1" ]]; then
      DOCS_FOLDER="$(dirname "$(realpath "$1")")"
      DOC_FILE="/home/gimp/Documents/$(basename "$1")"
      shift
      set -- "$@" "$DOC_FILE"
    elif [[ -d "$1" ]]; then
      DOCS_FOLDER="$(realpath "$1")"
      shift
    fi
  fi

  # TODO: unlike one of my other docker projects that uses pulse (firefox),
  # this audacity bogarts the sound card so only one thing can use it at once

  docker run --rm \
    --net host \
    -v "$HOME/.audacity-data:/home/audacity/.audacity-data" \
    -v "$HOME/.audacity-file:/home/audacity/.audacity-file" \
    -v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro \
    -v $XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse:ro \
    -v /dev/shm:/dev/shm \
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/machine-id:/etc/machine-id:ro \
    -v /run/dbus:/run/dbus:ro \
    -v /run/udev/data:/run/udev/data:ro \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro \
    -v "$DOCS_FOLDER":/home/audacity/Documents \
    -e "DISPLAY=$DISPLAY" \
    -e GDK_DPI_SCALE \
    -e GDK_SCALE \
    -e PGID=$(id -g) \
    -e PUID=$(id -u) \
    -e PULSE_LATENCY_MSEC=30 \
    -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    --device /dev/input \
    $(find /dev/snd/ -type c | sed 's/^/--device /') \
    --group-add $(getent group audio | cut -d: -f3) \
    --name audacity-$(date -u +%s) \
    ghcr.io/mmguero/audacity "$@"
