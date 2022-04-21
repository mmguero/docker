#!/usr/bin/env bash

GPU_DEVICES=$( \
    echo "$( \
        find /dev -maxdepth 1 -regextype posix-extended -iregex '.+/nvidia([0-9]|ctl)' \
            | grep --color=never '.' \
          || echo '/dev/dri'\
      )" \
      | sed -E "s/^/--device /" \
  )

if [[ ! -d "$HOME/.config/GIMP" ]]; then
  TMP_CONTAINER_ID=$(docker create ghcr.io/mmguero/gimp:latest)
  mkdir -p "$HOME/.config"
  docker cp $TMP_CONTAINER_ID:/home/gimp/.config/GIMP "$HOME/.config"/
  docker rm $TMP_CONTAINER_ID
fi

mkdir -p "$HOME/.fonts" "$HOME/.config/GIMP"

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

docker run -d --rm \
  -v /dev/shm:/dev/shm \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v /run/udev/data:/run/udev/data:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v "$HOME"/.config/GIMP:/home/gimp/.config/GIMP \
  -v "$HOME"/.fonts:/home/gimp/.fonts:ro \
  -v "$DOCS_FOLDER":/home/gimp/Documents \
  -e "DISPLAY=$DISPLAY" \
  -e GDK_DPI_SCALE \
  -e GDK_SCALE \
  -e PGID=$(id -g) \
  -e PUID=$(id -u) \
  --device /dev/input \
  $GPU_DEVICES \
  --name gimp-$(date -u +%s) \
  ghcr.io/mmguero/gimp:latest \
  --no-splash "$@"
