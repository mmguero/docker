FROM debian:bullseye-slim

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/firefox'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/firefox'
LABEL org.opencontainers.image.description='Dockerized Firefox (X11)'

#    function firefoxd() {
#
#      GPU_DEVICES=$( \
#          echo "$( \
#              find /dev -maxdepth 1 -regextype posix-extended -iregex '.+/nvidia([0-9]|ctl)' \
#                  | grep --color=never '.' \
#                || echo '/dev/dri'\
#            )" \
#            | sed -E "s/^/--device /" \
#        )
#
#      DOWNLOAD_DIR="$(type xdg-user-dir >/dev/null 2>&1 && xdg-user-dir DOWNLOAD || echo "$HOME/Downloads")"
#
#      mkdir -p "$DOWNLOAD_DIR" \
#               "$HOME"/.config/pulse \
#               "$HOME"/.mozilla/firefox \
#               "$HOME"/.cache/mozilla/firefox
#      export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
#
#      docker run --rm \
#        --net host \
#        -v "$HOME/.config/pulse:/home/firefox/.config/pulse" \
#        -v "$HOME/.mozilla/firefox:/home/firefox/.mozilla/firefox" \
#        -v "$HOME/.cache/mozilla/firefox:/home/firefox/.cache/mozilla/firefox" \
#        -v "$DOWNLOAD_DIR:/home/firefox/Downloads" \
#        -v $XDG_RUNTIME_DIR/bus:$XDG_RUNTIME_DIR/bus:ro \
#        -v $XDG_RUNTIME_DIR/pulse:$XDG_RUNTIME_DIR/pulse:ro \
#        -v /dev/shm:/dev/shm \
#        -v /etc/localtime:/etc/localtime:ro \
#        -v /etc/machine-id:/etc/machine-id:ro \
#        -v /run/dbus:/run/dbus:ro \
#        -v /run/udev/data:/run/udev/data:ro \
#        -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
#        -v /var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro \
#        -e "DISPLAY=$DISPLAY" \
#        -e GDK_DPI_SCALE \
#        -e GDK_SCALE \
#        -e PGID=$(id -g) \
#        -e PUID=$(id -u) \
#        -e PULSE_SERVER=unix:$XDG_RUNTIME_DIR/pulse/native \
#        --device /dev/input \
#        --device /dev/snd \
#        $GPU_DEVICES \
#        --group-add $(getent group audio | cut -d: -f3) \
#        --name firefox \
#        ghcr.io/mmguero/firefox "$@"
#    }

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# configure unprivileged user and runtime parameters
ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "firefox"
ENV PGROUP "firefox"
ENV PUSER_PRIV_DROP true

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD local.conf /etc/fonts/local.conf
ADD entrypoint.sh /usr/local/bin/firefox.sh

RUN sed -i "s/bullseye main/bullseye main contrib non-free/g" /etc/apt/sources.list && \
    apt-get -q update && \
    apt-get install --no-install-recommends -y -q \
      bzip2 \
      ca-certificates \
      curl \
      ffmpeg \
      fonts-noto \
      fonts-noto-color-emoji \
      hicolor-icon-theme \
      libdbus-glib-1-2 \
      libgl1-mesa-dri \
      libgl1-mesa-glx \
      libgtk-3-0 \
      pulseaudio-utils && \
    mkdir -p /opt/firefox && \
      cd /opt && \
      curl -ksSL "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" | tar xjvf - -C ./firefox --strip-components 1 && \
      mkdir -p /etc/firefox && \
      echo 'pref("browser.tabs.remote.autostart", false);' >> /etc/firefox/syspref.js && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y --purge remove curl && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh /usr/local/bin/firefox.sh && \
      groupadd --gid ${DEFAULT_GID} ${PUSER} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER} && \
      usermod -a -G audio ${PUSER} && \
      mkdir -p /etc/pulse/ && \
      touch /etc/pulse/client.conf && \
      chown root:audio /etc/pulse/client.conf && \
      chmod 664 /etc/pulse/client.conf && \
      mkdir -p /home/${PUSER}/.config/pulse \
               /home/${PUSER}/.mozilla/firefox \
               /home/${PUSER}/.cache/mozilla/firefox \
               /home/${PUSER}/Downloads && \
      chown -R ${DEFAULT_UID}:${DEFAULT_GID} /home/${PUSER}

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/firefox.sh"]
