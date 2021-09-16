#!/usr/bin/env bash

function dstopped(){
  local name=$1
  local state
  state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

  if [[ "$state" == "false" ]]; then
    docker rm "$name"
  fi
}

dstopped chromium

# detect gpu devices to pass through
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
         "$HOME"/.config/chromium
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# create the container
docker run -d --rm \
  --name chromium \
  --cap-add SYS_ADMIN \
  --security-opt apparmor:unconfined \
  --net host \
  --device /dev/input \
  --group-add $(getent group audio | cut -d: -f3) \
  $GPU_DEVICES \
  -v "$DOWNLOAD_DIR:/downloads" \
  -v "$HOME/.config/chromium:/data" \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e DISPLAY=unix$DISPLAY \
  -e LANG=${LANG:-en_US.UTF-8} \
  -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v /dev/shm:/dev/shm \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v $XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse:ro \
  -v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro \
  -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro \
  -v /run/dbus:/run/dbus:ro \
  -v /run/udev/data:/run/udev/data:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  andrewmackrodt/chromium-x11
