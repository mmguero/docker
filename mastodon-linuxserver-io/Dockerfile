FROM lscr.io/linuxserver/mastodon:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/mastodon-linuxserver-io'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/mastodon'
LABEL org.opencontainers.image.description='Dockerized Mastodon'

COPY ./mastodon_lsio_nginx_conf_no_https.patch /tmp/mastodon_lsio_nginx_conf_no_https.patch

RUN apk add --no-cache --virtual .build-deps patch && \
    cd /app/www/dist && \
    patch -p 1 -r - --no-backup-if-mismatch < /tmp/mastodon_lsio_nginx_conf_no_https.patch && \
    rm /tmp/mastodon_lsio_nginx_conf_no_https.patch && \
    apk del .build-deps
