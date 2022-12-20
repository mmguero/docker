FROM codeberg.org/forgejo/forgejo:1.18.0-rc1-1

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/forgejo'
LABEL org.opencontainers.image.description='Dockerized Forgejo unsafely running as root'

RUN sed -i '/^RUN_MODE[[:space:]]*=.*/a RUN_USER = root\nI_AM_BEING_UNSAFE_RUNNING_AS_ROOT = true' /etc/templates/app.ini
