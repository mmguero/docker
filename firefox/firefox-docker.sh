#!/usr/bin/env bash

function dstopped(){
  local name=$1
  local state
  state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

  if [[ "$state" == "false" ]]; then
    docker rm "$name"
  fi
}

dstopped firefox

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
         "$HOME"/.config/pulse \
         "$HOME"/.mozilla/firefox \
         "$HOME"/.cache/mozilla/firefox
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

docker run -d --rm \
  --net host \
  -v "$HOME/.config/pulse:/home/firefox/.config/pulse" \
  -v "$HOME/.mozilla/firefox:/home/firefox/.mozilla/firefox" \
  -v "$HOME/.cache/mozilla/firefox:/home/firefox/.cache/mozilla/firefox" \
  -v "$DOWNLOAD_DIR:/home/firefox/Downloads" \
  -v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro \
  -v $XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse:ro \
  -v /dev/shm:/dev/shm \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v /run/dbus:/run/dbus:ro \
  -v /run/udev/data:/run/udev/data:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro \
  -e "DISPLAY=$DISPLAY" \
  -e GDK_DPI_SCALE \
  -e GDK_SCALE \
  -e PGID=$(id -g) \
  -e PUID=$(id -u) \
  -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
  --device /dev/input \
  --device /dev/snd \
  $GPU_DEVICES \
  --group-add $(getent group audio | cut -d: -f3) \
  --name firefox \
  ghcr.io/mmguero/firefox "$@"
