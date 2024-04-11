#!/usr/bin/env bash

IMAGE="${GIMP_IMAGE:-oci.guero.top/gimp:latest}"
ENGINE="${CONTAINER_ENGINE:-docker}"
if [[ "$ENGINE" == "podman" ]]; then
  CONTAINER_PUID=0
  CONTAINER_PGID=0
else
  CONTAINER_PUID=$(id -u)
  CONTAINER_PGID=$(id -g)
fi

if [[ ! -d "$HOME/.config/GIMP" ]]; then
  TMP_CONTAINER_ID="$($ENGINE run --detach --rm --entrypoint=sleep "$IMAGE" infinity)"
  mkdir -p "$HOME/.config"
  $ENGINE cp $TMP_CONTAINER_ID:/home/gimp/.config/GIMP "$HOME/.config"/
  $ENGINE stop $TMP_CONTAINER_ID
  find "$HOME/.config/GIMP" -type d -exec chmod 700 "{}" \;
  find "$HOME/.config/GIMP" -type f -exec chmod 600 "{}" \;
fi

mkdir -p "$HOME/.fonts" "$HOME/.local/share/fonts" "$HOME/.config/GIMP"

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

if [[ "$(realpath "$DOCS_FOLDER")" == "$(realpath "$HOME")" ]]; then
  echo "\$DOCS_FOLDER needs to be a directory other than \"$HOME\"" >&2
  exit 1
fi

# TODO: detect how to handle --gpus all?

$ENGINE run -d --rm \
  -v /dev/shm:/dev/shm \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v /run/udev/data:/run/udev/data:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v "$HOME"/.config/GIMP:/home/gimp/.config/GIMP \
  -v "$HOME"/.fonts:/home/gimp/.fonts:ro \
  -v "$HOME"/.local/share/fonts:/home/gimp/.local/share/fonts:ro \
  -v "$DOCS_FOLDER":/home/gimp/Documents \
  -e "DISPLAY=$DISPLAY" \
  -e GDK_DPI_SCALE \
  -e GDK_SCALE \
  -e PGID=$CONTAINER_PGID \
  -e PUID=$CONTAINER_PUID \
  --device /dev/input \
  --name gimp-$(date -u +%s) \
  "$IMAGE" \
  --no-splash "$@"
