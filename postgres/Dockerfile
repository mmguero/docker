FROM postgres:18-alpine

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID=$DEFAULT_UID
ENV DEFAULT_GID=$DEFAULT_GID
ENV PUSER="postgres"
ENV PGROUP="postgres"
ENV PUSER_PRIV_DROP=true
ENV PUSER_CHOWN="/run/postgresql;/var/lib/postgresql"
USER root

ENV TERM=xterm

COPY --from=ghcr.io/mmguero-dev/gostatic --chmod=755 /goStatic /usr/bin/goStatic
ADD --chmod=755 https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/bin/docker-uid-gid-setup.sh
ADD --chmod=755 https://raw.githubusercontent.com/mmguero/docker/master/shared/service_check_passthrough.sh /usr/bin/service_check_passthrough.sh
ADD --chmod=755 scripts/docker-entrypoint-initdb.d/*.sh /docker-entrypoint-initdb.d/
ADD --chmod=755 scripts/docker-entrypoint-startdb.d/*.sh /docker-entrypoint-startdb.d/
ADD --chmod=755 scripts/*.sh /usr/local/bin/

ENV PGDATA=/var/lib/postgresql/data

RUN apk update --no-cache && \
    apk add --no-cache bash jq musl-locales procps psmisc rsync shadow tini && \
    # NOTE: as this moves image forward, add old supported versions
    # here for version-to-version upgrades (e.g., postgresql18 postgresql18-contrib)
    apk add --no-cache \
        postgresql16 postgresql16-contrib \
        postgresql17 postgresql17-contrib && \
    rsync -a /usr/local/bin/ /usr/bin/ && \
    rsync -a /usr/local/share/ /usr/share/ && \
    rsync -a /usr/local/lib/ /usr/lib/ && \
    rm -rf /usr/local/bin /usr/local/share /usr/local/lib && \
    ln -s /usr/bin /usr/local/bin && \
    ln -s /usr/share /usr/local/share && \
    ln -s /usr/lib /usr/local/lib && \
    mkdir -p "${PGDATA}" && \
    chmod 00775 /var/lib/postgresql /var/lib/postgresql/data /run/postgresql

USER root

ENTRYPOINT ["/sbin/tini", \
            "--", \
            "/usr/bin/docker-uid-gid-setup.sh", \
            "/usr/local/bin/service_check_passthrough.sh", \
            "-s", "postgres", \
            "/usr/bin/docker-entrypoint-startdb.sh"]

CMD ["/usr/bin/docker-entrypoint.sh", "postgres"]
