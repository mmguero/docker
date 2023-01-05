FROM debian:bullseye-slim

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "user"
ENV PGROUP "user"

ENV PUSER_PRIV_DROP true

ARG GITHUB_TOKEN

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
COPY --chmod=755 external_tools_install.sh /usr/local/bin/

RUN sed -i "s/bullseye main/bullseye main contrib non-free/g" /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list && \
    apt-get -q update && \
    apt-get install -q -y -t bullseye-backports --no-install-recommends \
        fasttrack-archive-keyring && \
    echo "deb https://fasttrack.debian.net/debian/ bullseye-fasttrack main contrib non-free" >> /etc/apt/sources.list && \
    apt-get -y -q --no-install-recommends upgrade && \
    apt-get install -q -y -t bullseye-backports --no-install-recommends \
        autossh \
        bash \
        bc \
        bzip2 \
        ca-certificates \
        curl \
        direnv \
        file \
        git \
        gpg \
        iproute2 \
        iputils-ping \
        jq \
        less \
        lz4 \
        moreutils \
        ncat \
        netcat-openbsd \
        openssh-client \
        procps \
        psmisc \
        pv \
        p7zip-full \
        p7zip-rar \
        ripgrep \
        rsync \
        socat \
        sqlite3 \
        stunnel \
        sudo \
        telnet \
        unzip \
        vim-tiny \
        w3m \
        wget \
        whois \
        xz-utils \
        zip \
        zlib1g && \
    sed -i "s/set[[:space:]]*compatible/set nocompatible/g" /etc/vim/vimrc.tiny && \
    groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /home/${PUSER} ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
      chsh -s /bin/bash ${PUSER} && \
      usermod -a -G sudo ${PUSER} && \
      echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    GITHUB_TOKEN=$GITHUB_TOKEN /usr/local/bin/external_tools_install.sh && \
    apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/bin/external_tools_install.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-uid-gid-setup.sh"]

ENTRYPOINT /bin/bash
