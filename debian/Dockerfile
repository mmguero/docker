FROM debian:stable-slim

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "user"
ENV PGROUP "user"

ENV PUSER_PRIV_DROP true

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN export DEB_ARCH=$(dpkg --print-architecture) && \
    export LINUX_CPU=$(uname -m) && \
    sed -i "s/bullseye main/bullseye main contrib non-free/g" /etc/apt/sources.list && \
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
        vim-tiny \
        zlib1g && \
    if [ $DEB_ARCH = arm* ]; then \
      if [ $LINUX_CPU = aarch64 ]; then \
        export STARSHIP_RELEASE_FILENAME=starship-aarch64-unknown-linux-musl.tar.gz; \
      else \
        export STARSHIP_RELEASE_FILENAME=starship-arm-unknown-linux-musleabihf.tar.gz; \
      fi; \
    else \
      export STARSHIP_RELEASE_FILENAME=starship-x86_64-unknown-linux-gnu.tar.gz; \
    fi; \
    cd /tmp && \
        curl -o ./starship.tar.gz -sSL "https://github.com/starship/starship/releases/latest/download/$STARSHIP_RELEASE_FILENAME" && \
        tar xf ./starship.tar.gz && \
        mv ./starship /usr/bin/starship && \
        chmod 755 /usr/bin/starship && \
    curl -o ./getcroc.sh -sSL "https://getcroc.schollz.com" && \
        chmod +x ./getcroc.sh && \
        ./getcroc.sh -p /usr/bin >/dev/null 2>&1 && \
    sed -i "s/set[[:space:]]*compatible/set nocompatible/g" /etc/vim/vimrc.tiny && \
    groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /home/${PUSER} ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
      chsh -s /bin/bash ${PUSER} && \
      usermod -a -G sudo ${PUSER} && \
      echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    ln -s -r /usr/bin/batcat /usr/bin/bat && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-uid-gid-setup.sh"]
