FROM ghcr.io/mmguero/xfce-base:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/xfce'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/xfce:latest'
LABEL org.opencontainers.image.description='Dockerized XFCE with my own special blend of herbs and spices'

# liberally steal some package lists and config scripts from my live USB image setup one of my other repos
#   https://github.com/mmguero/deblive/
ARG PACKAGE_CATEGORY_URL_PREFIX="https://raw.githubusercontent.com/mmguero/deblive/master/bullseye/config"

RUN sed -i "s/bullseye main/bullseye main contrib non-free/g" /etc/apt/sources.list && \
    apt-get -q update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
      bash \
      bc \
      bzip2 \
      ca-certificates \
      cpio \
      curl \
      diffutils \
      dirmngr \
      file \
      findutils \
      fonts-hack-ttf \
      git \
      gnome-themes-extra \
      gnupg2 \
      jq \
      keepassxc \
      less \
      libdbus-glib-1-2 \
      libsecret-1-0 \
      libsecret-1-dev \
      libsecret-tools \
      moreutils \
      openssh-client \
      openssh-sftp-server \
      patchutils \
      pigz \
      procps \
      psmisc \
      pv \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      rar \
      rename \
      rsync \
      testdisk \
      tilix \
      unrar \
      unzip \
      vim-tiny \
      wget \
      xxdiff \
      xz-utils && \
    for CATEGORY in apps multimedia net; do \
      for PACKAGE in $(curl -sSL "$PACKAGE_CATEGORY_URL_PREFIX/package-lists/$CATEGORY.list.chroot" | grep -Pvi "abiword|audac(ious|ity)|brasero|bridge-utils|cdparanoia|cheese|gimp|gnumeric|handbrake|libdvd-pkg|motion|open(jdk|vpn)|pidgin|purple|resolvconf|sshuttle|(t|wire)shark|ufw|wireguard"); do \
        env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q "$PACKAGE"; \
      done; \
    done && \
    curl -sSL -o /tmp/sublime.deb "$(curl -sSL "https://www.sublimetext.com/3"|grep "sublime-text_build-3.*$(dpkg --print-architecture).deb\"" | sed 's/[[:space:]]*<a href="//' | sed 's/">.*//')" && \
      env DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/sublime.deb && \
    curl -sSL -o /tmp/install_pip_pkgs.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0169-pip-installs.hook.chroot" && \
      bash /tmp/install_pip_pkgs.sh && \
    curl -sSL -o /tmp/install_firefox.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0168-firefox-install.hook.chroot" && \
      bash /tmp/install_firefox.sh && \
    curl -sSL -o /tmp/install_custom_bins.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0911-custom-binaries.hook.chroot" && \
      bash /tmp/install_custom_bins.sh && \
    curl -sSL -o /tmp/setup_skel.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0998-skel-setup.hook.chroot" && \
      bash /tmp/setup_skel.sh && \
      rm -rf /etc/skel/.bashrc.d/07_keyring.bashrc \
             /etc/skel/.config/mmguero.docker && \
    git clone https://github.com/asdf-vm/asdf.git /etc/skel/.asdf && \
    curl -sSL -o /tmp/localepurge.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0992-localepurge.hook.chroot" && \
      bash /tmp/localepurge.sh && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y --purge remove openjdk-11-jre-headless && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/*
