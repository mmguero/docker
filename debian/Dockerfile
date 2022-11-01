FROM debian:stable-slim

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "user"
ENV PGROUP "user"

ENV PUSER_PRIV_DROP true

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
COPY --chmod=755 external_tools_install.sh /usr/local/bin/

RUN sed -i "s/bullseye main/bullseye main contrib non-free/g" /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list && \
    apt-get -q update && \
    apt-get -y -q --no-install-recommends upgrade && \
    apt-get install -q -y -t bullseye-backports --no-install-recommends \
        bash \
        bat \
        bc \
        ca-certificates \
        curl \
        direnv \
        exa \
        fd-find \
        file \
        git \
        gpg \
        iproute2 \
        iputils-ping \
        jq \
        less \
        moreutils \
        peco \
        procps \
        psmisc \
        pv \
        ripgrep \
        sudo \
        tini \
        unzip \
        vim-tiny \
        xz-utils \
        zlib1g && \
    sed -i "s/set[[:space:]]*compatible/set nocompatible/g" /etc/vim/vimrc.tiny && \
    groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /home/${PUSER} ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
      chsh -s /bin/bash ${PUSER} && \
      usermod -a -G sudo ${PUSER} && \
      echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    ln -s -r /usr/bin/batcat /usr/bin/bat && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    external_tools_install.sh && \
    apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-uid-gid-setup.sh"]
