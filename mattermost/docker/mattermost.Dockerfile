FROM debian:bookworm-slim

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/mattermost'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/mattermost-server'
LABEL org.opencontainers.image.description='Dockerized Mattermost Server'

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN set -eux; \
  apt-get update; \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    openssl \
    curl \
    gnupg && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

ARG MATTERMOST_VERSION=6.3.5
ENV MATTERMOST_VERSION $MATTERMOST_VERSION

ADD https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-${MATTERMOST_VERSION}-linux-amd64.tar.gz /

RUN tar -xzf /mattermost-${MATTERMOST_VERSION}-linux-amd64.tar.gz && \
    mv /mattermost /opt/. && \
    rm -rf /mattermost-${MATTERMOST_VERSION}-linux-amd64.tar.gz

COPY config.json.template /opt/mattermost/config/config.json

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "mattermost"
ENV PGROUP "mattermost"
ENV PUSER_PRIV_DROP true

RUN chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
  groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
  useradd -M --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /nonexistant ${PUSER} && \
  usermod -a -G tty ${PUSER} && \
  chown -R $PUSER:$PGROUP /opt/mattermost

VOLUME ["/opt/mattermost/data", "/opt/mattermost/plugins", "/opt/mattermost/export", "/opt/mattermost/import", "/opt/mattermost/client_plugins"]

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/opt/mattermost/bin/mattermost", "-c", "/opt/mattermost/config/config.json", "server"]
