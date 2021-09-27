FROM debian:bullseye-slim

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
ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "audacity"
ENV PGROUP "audacity"
ENV PUSER_PRIV_DROP true

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD entrypoint.sh /usr/local/bin/audacity.sh

RUN sed -i "s/bullseye main/bullseye main contrib non-free/g" /etc/apt/sources.list && \
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
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh /usr/local/bin/audacity.sh && \
      groupadd --gid ${DEFAULT_GID} ${PUSER} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER} && \
      usermod -a -G audio ${PUSER} && \
      mkdir -p /etc/pulse/ && \
      touch /etc/pulse/client.conf && \
      chown root:audio /etc/pulse/client.conf && \
      chmod 664 /etc/pulse/client.conf && \
      mkdir -p /home/${PUSER}/.audacity-data \
               /home/${PUSER}/.audacity-file && \
      chown -R ${DEFAULT_UID}:${DEFAULT_GID} /home/${PUSER}

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/audacity.sh"]
