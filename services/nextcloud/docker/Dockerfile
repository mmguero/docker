FROM nextcloud:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/services/nextcloud'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='mmguero/nextcloud'
LABEL org.opencontainers.image.description='Dockerized Nextcloud'

RUN apt-get update && \
    apt-get -y -q --no-install-recommends install smbclient && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

