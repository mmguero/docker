# docker run -d --rm \
#   -v /tmp/.X11-unix:/tmp/.X11-unix \
#   -e DISPLAY=unix\$DISPLAY \
# --device /dev/video0 \
# --device /dev/snd:/dev/snd \
# --device /dev/dri \
# -v /dev/shm:/dev/shm \
# signal

FROM debian:buster-slim

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/comm/signal'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='mmguero/signal'
LABEL org.opencontainers.image.description='Dockerized Signal (X11)'

ENV DEBIAN_FRONTEND noninteractive

ENV SIGNAL_USER signaler

RUN sed -i "s/buster main/buster main contrib non-free/g" /etc/apt/sources.list && \
      echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
      apt-get -q update && \
      apt-get install -q -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg2 \
        libasound2 \
        libgtk-3-0 \
        libx11-xcb1 \
        libxkbfile1 && \
  bash -c "curl -sSL https://updates.signal.org/desktop/apt/keys.asc | apt-key add -" && \
    echo "deb https://updates.signal.org/desktop/apt xenial main" >> /etc/apt/sources.list && \
  apt-get -q update && \
  apt-get install -q -y -t buster-backports --no-install-recommends signal-desktop && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --gid 1000 ${SIGNAL_USER} && \
    useradd -m --uid 1000 --gid 1000 ${SIGNAL_USER}

USER $SIGNAL_USER

WORKDIR /opt/Signal

CMD [ "./signal-desktop", "--no-sandbox" ]