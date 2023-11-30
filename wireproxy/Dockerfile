FROM golang:1.20 as build

RUN mkdir -p /usr/src && \
    cd /usr/src && \
    git clone --recurse-submodules --shallow-submodules --single-branch --depth 1 https://github.com/pufferffish/wireproxy && \
    cd ./wireproxy && \
    make

FROM debian:11-slim AS runtime

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/wireproxy'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/wireproxy'
LABEL org.opencontainers.image.description='Dockerized wireproxy'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "wired"
ENV PGROUP "wired"
ENV PUSER_PRIV_DROP true

# false - read /etc/wireproxy/config from bind-mounted file
# true - generate /etc/wireproxy/config from environment variables
ENV WIREPROXY_CONFIG_FROM_ENVS false

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config.env /etc/wireproxy/config.env

RUN apt-get -q update && \
    apt-get -y -q --no-install-recommends upgrade && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages install --no-install-recommends \
      bash gettext-base rsync && \
    groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --no-create-home --home /var/www/html -s /sbin/nologin ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
      chown -R ${PUSER}:${PGROUP} /etc/wireproxy && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh /usr/local/bin/entrypoint.sh

COPY --from=build /usr/src/wireproxy/wireproxy /usr/bin/wireproxy

VOLUME [ "/etc/wireproxy"]

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/entrypoint.sh"]
