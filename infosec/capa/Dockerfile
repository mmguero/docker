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

ENV CAPA_URL "https://github.com/fireeye/capa"
ENV CAPA_RULES_DIR "/opt/capa-rules"

RUN apt-get update && \
    apt-get  -y -q install --no-install-recommends \
      git \
      python \
      python-backports-shutil-get-terminal-size \
      python-dev \
      python-pkg-resources \
      python-setuptools \
      python-wheel \
      python-pip && \
    pip2 install flare-capa && \
    cd /tmp && \
      git clone --depth 1 --single-branch --branch "v$(/usr/local/bin/capa --version 2>&1 | awk '{print $2}')" "${CAPA_URL}" /tmp/capa && \
      cd /tmp/capa && \
      git submodule init rules && \
      git submodule update --depth 1 rules && \
      cd /tmp && \
      rm -rf "${CAPA_RULES_DIR}" && \
      mv /tmp/capa/rules "${CAPA_RULES_DIR}" && \
      rm -rf "${CAPA_RULES_DIR}"/.git* /tmp/capa && \
    apt-get -q -y --purge remove git ca-certificates git python-dev && \
    apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://raw.githubusercontent.com/mmguero-personal/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
    useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER}

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh", "/usr/local/bin/capa", "-r", "/opt/capa-rules" ]
