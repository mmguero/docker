FROM golang:latest as build

RUN mkdir -p /usr/src && \
    cd /usr/src && \
    git clone --recurse-submodules --shallow-submodules --single-branch --depth 1 https://github.com/go-debos/fakemachine && \
    cd ./fakemachine/cmd/fakemachine && \
    go build .

FROM tianon/qemu:native

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/fakemachine'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/fakemachine'
LABEL org.opencontainers.image.description='Dockerized fakemachine'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "fakemachine"
ENV PGROUP "fakemachine"
ENV PUSER_PRIV_DROP true

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN apt-get -q update && \
    apt-get -y -q --no-install-recommends upgrade && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages install --no-install-recommends \
      bash \
      busybox \
      libslirp-helper \
      procps \
      psmisc \
      rsync \
      tini \
      user-mode-linux && \
    apt-get -y autoremove -qq && \
    apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
      useradd -M --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /nonexistant ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh

COPY --from=build --chmod=755 /usr/src/fakemachine/cmd/fakemachine/fakemachine /usr/bin/fakemachine

ENTRYPOINT ["/usr/bin/tini", \
            "--", \
            "/usr/local/bin/docker-uid-gid-setup.sh", \
            "/usr/bin/fakemachine"]
