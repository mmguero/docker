FROM debian:buster-slim

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "capa"
ENV PGROUP "capa"
ENV PUSER_PRIV_DROP true

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ARG CAPA_VERSION="1.0.0"
ARG CAPA_URL="https://github.com/fireeye/capa/releases/download/v${CAPA_VERSION}/capa-v${CAPA_VERSION}-linux.zip"

RUN apt-get update && \
    apt-get  -y -q install --no-install-recommends \
      curl unzip ca-certificates && \
    cd /tmp && \
        curl -sSL -o ./capa.zip "${CAPA_URL}" && \
        unzip ./capa.zip && \
        mv "/tmp/capa-v${CAPA_VERSION}-linux" /usr/bin/ && \
        chmod +x "/usr/bin/capa-v${CAPA_VERSION}-linux" && \
        ln -s -r "/usr/bin/capa-v${CAPA_VERSION}-linux" /usr/bin/capa && \
        rm -f ./capa.zip && \
    apt-get -q -y --purge remove curl unzip ca-certificates && \
    apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --gid ${DEFAULT_GID} ${PUSER} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER}

ADD ./docker/docker-uid-gid-setup.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh", "/usr/bin/capa", "-vv" ]
