FROM debian:bookworm-slim

# x11docker --alsa $(find /dev/snd/ -type c | sed 's/^/--share /') ghcr.io/mmguero/audacity

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/audacity'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/audacity'
LABEL org.opencontainers.image.description='Dockerized Audacity (X11)'

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# configure unprivileged user and runtime parameters
ARG PUID=1000
ARG PGID=1000
ENV PUID $PUID
ENV PGID $PGID
ENV PUSER "audacity"
ENV PGROUP "audacity"

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/debian-bookworm-sources.list /etc/apt/sources.list

RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    apt-get -q update && \
    apt-get install --no-install-recommends -y -q \
      audacity \
      libdbus-glib-1-2 \
      gnome-icon-theme \
      pulseaudio-utils && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y --purge remove curl && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd --gid ${PGID} ${PUSER} && \
      useradd -m --uid ${PUID} --gid ${PGID} ${PUSER} && \
      usermod -a -G audio ${PUSER} && \
      mkdir -p /etc/pulse/ && \
      touch /etc/pulse/client.conf && \
      chown root:audio /etc/pulse/client.conf && \
      chmod 664 /etc/pulse/client.conf && \
      mkdir -p /home/${PUSER}/.audacity-data \
               /home/${PUSER}/.audacity-file && \
      chown -R ${PUID}:${PGID} /home/${PUSER}

ENTRYPOINT ["/usr/bin/audacity"]