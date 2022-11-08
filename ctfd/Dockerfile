FROM ctfd/ctfd:3.5.0

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/ctfd'
LABEL org.opencontainers.image.description='Dockerized CTFd'

ARG DEFAULT_UID=1001
ARG DEFAULT_GID=1001
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "ctfd"
ENV PGROUP "ctfd"
ENV PUSER_PRIV_DROP true
ENV PUSER_CHOWN "/opt/CTFd;/var/log/CTFd;/var/uploads"

ENV TERM xterm

USER root

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/bin/docker-uid-gid-setup.sh

RUN mkdir -p /opt/CTFd /var/log/CTFd /var/uploads && \
    chown -R $PUSER:$PGROUP /opt/CTFd /var/log/CTFd /var/uploads && \
    chmod 755 /usr/bin/docker-uid-gid-setup.sh

ENTRYPOINT ["/usr/bin/docker-uid-gid-setup.sh", "/opt/CTFd/docker-entrypoint.sh"]
