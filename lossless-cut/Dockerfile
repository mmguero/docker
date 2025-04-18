FROM debian:bookworm-slim

# https://github.com/mifi/lossless-cut
# x11docker --pulseaudio --gpu oci.guero.org/lossless-cut:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/lossless-cut'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.org/lossless-cut'
LABEL org.opencontainers.image.description='Dockerized LosslessCut'

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# configure unprivileged user and runtime parameters
ARG PUID=1000
ARG PGID=1000
ENV PUID $PUID
ENV PGID $PGID
ENV PUSER "cutter"
ENV PGROUP "cutter"

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/debian-bookworm-sources.list /etc/apt/sources.list

RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    apt-get -q update && \
    apt-get install --no-install-recommends -y -q \
      bzip2 \
      ca-certificates \
      curl \
      libasound2 \
      libdbus-glib-1-2 \
      libdrm2 \
      libgbm1 \
      libgdk-pixbuf-2.0-0 \
      libgtk-3-0 \
      libnss3 \
      libnss3-tools \
      libxcomposite1 \
      libxcursor1 \
      libxdamage1 \
      libxfixes3 \
      libxrender1 \
      libxss1 \
      pulseaudio-utils && \
    mkdir -p /opt && \
    cd /opt && \
      curl -sSL -J -O "https://github.com/mifi/lossless-cut/releases/latest/download/LosslessCut-linux-x64.tar.bz2" && \
      tar xvf ./LosslessCut-linux-x64.tar.bz2 && \
      rm -f ./LosslessCut-linux-x64.tar.bz2 && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y --purge remove curl ca-certificates && \
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
      mkdir -p /home/${PUSER}/Videos && \
      chown -R ${PUID}:${PGID} /home/${PUSER}

ENV LD_LIBRARY_PATH=/opt/LosslessCut-linux-x64

ENTRYPOINT ["/opt/LosslessCut-linux-x64/losslesscut", "--no-sandbox"]
