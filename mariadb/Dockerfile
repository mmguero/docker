FROM mariadb:10-jammy

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/mariadb'
LABEL org.opencontainers.image.description='Dockerized MariaDB'

ARG DEFAULT_UID=999
ARG DEFAULT_GID=999
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "mysql"
ENV PGROUP "mysql"
ENV PUSER_PRIV_DROP true
ENV PUSER_CHOWN "/var/log/mysql;/var/lib/mysql"

ENV TERM xterm

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/bin/docker-uid-gid-setup.sh

RUN mkdir -p /var/lib/mysql /var/log/mysql /home/mysql && \
    chown -R $PUSER:$PGROUP /var/lib/mysql /var/log/mysql /home/mysql && \
    sed -i 's/\(if.*id[[:space:]]-u.*\);/\1 \&\& [ "${PUSER_PRIV_DROP:-true}" != "false" ];/' /usr/local/bin/docker-entrypoint.sh && \
    chmod 755 /usr/bin/docker-uid-gid-setup.sh

USER root

WORKDIR /home/mysql

ENTRYPOINT ["/usr/bin/docker-uid-gid-setup.sh", "/usr/local/bin/docker-entrypoint.sh"]

CMD ["mysqld"]
