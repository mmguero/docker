# docker run -d --rm \
#   -v /tmp/.X11-unix:/tmp/.X11-unix \
#   -e DISPLAY=unix\$DISPLAY \
# --device /dev/video0 \
# --device /dev/snd:/dev/snd \
# --device /dev/dri \
# -v /dev/shm:/dev/shm \
# teams

FROM debian:buster-slim

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/teams'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/teams'
LABEL org.opencontainers.image.description='Dockerized Microsoft Teams (X11)'

ENV DEBIAN_FRONTEND noninteractive

ENV TEAMS_USER teams

RUN sed -i "s/buster main/buster main contrib non-free/g" /etc/apt/sources.list && \
      echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
      apt-get -q update && \
      apt-get install -q -y --no-install-recommends gnupg2 curl ca-certificates libsecret-1-0 libsecret-tools && \
  bash -c "curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -" && \
    echo "deb https://packages.microsoft.com/repos/ms-teams stable main" >> /etc/apt/sources.list && \
  apt-get -q update && \
  apt-get install -q -y -t buster-backports --no-install-recommends teams && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --gid 1000 ${TEAMS_USER} && \
    useradd -m --uid 1000 --gid 1000 ${TEAMS_USER}

USER $TEAMS_USER

WORKDIR /usr/share/teams

CMD [ "./teams" ]