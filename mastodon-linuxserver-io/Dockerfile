FROM lscr.io/linuxserver/mastodon:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/mastodon-linuxserver-io'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/mastodon'
LABEL org.opencontainers.image.description='Dockerized Mastodon'

RUN sed -i -n '/^[[:space:]]*listen.*[::]/!p' /defaults/nginx/site-confs/default.conf.sample && \
    sed -i -n '/^[[:space:]]*listen.*[::]/!p' /app/www/dist/nginx.conf
