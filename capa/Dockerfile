FROM debian:bookworm-slim

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/capa'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.org/capa'
LABEL org.opencontainers.image.description='Dockerized capa'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "capa"
ENV PGROUP "capa"
ENV PUSER_PRIV_DROP true

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ENV CAPA_VERSION "9.1.0"
ENV CAPA_URL "https://github.com/fireeye/capa/releases/download/v${CAPA_VERSION}/capa-v${CAPA_VERSION}-linux.zip"
ENV CAPA_DIR "/opt/capa"
ENV CAPA_BIN "${CAPA_DIR}/capa"

ADD "$CAPA_URL" /tmp/capa.zip

RUN apt-get update && \
    apt-get install --no-install-recommends -y -q \
      unzip && \
    cd /tmp && \
      unzip ./capa.zip && \
      chmod 755 ./capa && \
      mkdir -p "${CAPA_DIR}" && \
      mv ./capa "${CAPA_BIN}" && \
      rm -f ./capa.zip && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages --purge remove \
      unzip && \
    apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
    useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER}

ENV PATH "${CAPA_DIR}:${PATH}"

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh", "${CAPA_BIN}" ]
