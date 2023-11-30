#!/usr/bin/env bash

ENGINE="${CONTAINER_ENGINE:-docker}"
if [[ "$ENGINE" == "podman" ]]; then
  CONTAINER_PUID=0
  CONTAINER_PGID=0
else
  CONTAINER_PUID=$(id -u)
  CONTAINER_PGID=$(id -g)
fi

function dstopped(){
  local name=$1
  local state
  state=$($ENGINE inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

  if [[ "$state" == "false" ]]; then
    $ENGINE rm "$name"
  fi

  echo "$state"
}

state=$(dstopped firefox)

if [[ "$state" == "true" ]]; then
  $ENGINE exec -u $CONTAINER_PUID -d firefox /opt/firefox/firefox --new-tab --url "$@"

else
  GPU_DEVICES=$( \
      echo "$( \
          find /dev -maxdepth 1 -regextype posix-extended -iregex '.+/nvidia([0-9]|ctl)' \
              | grep --color=never '.' \
            || echo '/dev/dri'\
        )" \
        | sed -E "s/^/--device /" \
    )

  DOWNLOAD_DIR="$(type xdg-user-dir >/dev/null 2>&1 && xdg-user-dir DOWNLOAD || echo "$HOME/Downloads")"

  mkdir -p "$DOWNLOAD_DIR" \
           "$HOME"/.mozilla/firefox \
           "$HOME"/.cache/mozilla/firefox
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

  $ENGINE run -d --rm \
    --net host \
    -v "$HOME/.mozilla/firefox:/home/firefox/.mozilla/firefox" \
    -v "$HOME/.cache/mozilla/firefox:/home/firefox/.cache/mozilla/firefox" \
    -v "$DOWNLOAD_DIR:/home/firefox/Downloads" \
    -v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro \
    -v $XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse:ro \
    -v /dev/shm:/dev/shm \
    -v /tmp:/tmp \
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/timezone:/etc/timezone:ro \
    -v /etc/machine-id:/etc/machine-id:ro \
    -v /run/dbus:/run/dbus:ro \
    -v /run/udev/data:/run/udev/data:ro \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro \
    -e "DISPLAY=$DISPLAY" \
    -e GDK_DPI_SCALE \
    -e GDK_SCALE \
    -e PGID=$CONTAINER_PGID \
    -e PUID=$CONTAINER_PUID \
    -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
    -e TZ="$(head -n 1 /etc/timezone)" \
    --device /dev/input \
    $GPU_DEVICES \
    --group-add $(getent group audio | cut -d: -f3) \
    --name firefox \
    oci.guero.top/firefox "$@"
fi