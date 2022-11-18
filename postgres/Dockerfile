FROM postgres:14-alpine

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/postgres'
LABEL org.opencontainers.image.description='Dockerized PostgreSQL'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "postgres"
ENV PGROUP "postgres"
ENV PUSER_PRIV_DROP true
ENV PUSER_CHOWN "/run/postgresql;/var/lib/postgresql"

ENV TERM xterm

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/bin/docker-uid-gid-setup.sh

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache bash procps psmisc shadow tini && \
    apk add --no-cache --virtual .build-deps rsync && \
    rsync -a /usr/local/bin/ /usr/bin/ && \
    rsync -a /usr/local/share/ /usr/share/ && \
    rsync -a /usr/local/lib/ /usr/lib/ && \
    rm -rf /usr/local/bin /usr/local/share /usr/local/lib && \
    ln -s /usr/bin /usr/local/bin && \
    ln -s /usr/share /usr/local/share && \
    ln -s /usr/lib /usr/local/lib && \
    apk del .build-deps && \
    chmod 755 /usr/bin/docker-uid-gid-setup.sh && \
    sed -i 's/\(if.*id[[:space:]]-u.*\);/\1 \&\& [ "${PUSER_PRIV_DROP:-true}" != "false" ];/' /usr/local/bin/docker-entrypoint.sh

USER root

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/bin/docker-entrypoint.sh", "postgres"]
