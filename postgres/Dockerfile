FROM postgres:17-alpine

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.org/postgres'
LABEL org.opencontainers.image.description='Dockerized PostgreSQL'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "postgres"
ENV PGROUP "postgres"
ENV PUSER_PRIV_DROP true
ENV PUSER_CHOWN "/run/postgresql;/var/lib/postgresql"
USER root

ENV TERM xterm

ADD --chmod=755 https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/bin/docker-uid-gid-setup.sh
ADD --chmod=755 scripts/docker-entrypoint-initdb.d/*.sh /docker-entrypoint-initdb.d/
ADD --chmod=755 scripts/docker-entrypoint-startdb.d/*.sh /docker-entrypoint-startdb.d/
ADD --chmod=755 scripts/*.sh /usr/bin/

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache bash jq procps psmisc shadow tini && \
    apk add --no-cache --virtual .build-deps rsync && \
    rsync -a --no-o --no-g --no-perms /usr/local/bin/ /usr/bin/ && \
    rsync -a --no-o --no-g --no-perms /usr/local/share/ /usr/share/ && \
    rsync -a --no-o --no-g --no-perms /usr/local/lib/ /usr/lib/ && \
    rm -rf /usr/local/bin /usr/local/share /usr/local/lib && \
    ln -s /usr/bin /usr/local/bin && \
    ln -s /usr/share /usr/local/share && \
    ln -s /usr/lib /usr/local/lib && \
    apk del .build-deps && \
    chmod 00775 /var/lib/postgresql /var/lib/postgresql/data /run/postgresql && \
    sed -i 's/\(if.*id[[:space:]]-u.*\);/\1 \&\& [ "${PUSER_PRIV_DROP:-true}" != "false" ];/' /usr/local/bin/docker-entrypoint.sh


ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/docker-uid-gid-setup.sh"]

ENTRYPOINT ["/sbin/tini", \
            "--", \
            "/usr/bin/docker-uid-gid-setup.sh", \
            "/usr/bin/docker-entrypoint-startdb.sh"]

CMD ["/usr/bin/docker-entrypoint.sh", "postgres"]
