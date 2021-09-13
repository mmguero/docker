FROM x11docker/xfce:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/desktop/xfce'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/xfce-plus:latest'
LABEL org.opencontainers.image.description='Dockerized XFCE with my own special blend of herbs and spices'

# liberally steal some package lists and config scripts from my live USB image setup one of my other repos
#   https://github.com/mmguero/deblive/
ARG PACKAGE_CATEGORY_URL_PREFIX="https://raw.githubusercontent.com/mmguero/deblive/master/bullseye/config"

RUN sed -i "s/bullseye main/bullseye main contrib non-free/g" /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list && \
    apt-get -q update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
      bash \
      bzip2 \
      ca-certificates \
      curl \
      file \
      git \
      jq \
      libdbus-glib-1-2 \
      moreutils \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      tilix \
      unzip \
      xz-utils && \
    for CATEGORY in apps multimedia net; do \
      for PACKAGE in $(curl -sSL "$PACKAGE_CATEGORY_URL_PREFIX/package-lists/$CATEGORY.list.chroot" | grep -Pvi "abiword|audac(ious|ity)|brasero|bridge-utils|cdparanoia|cheese|gimp|gnumeric|handbrake|libdvd-pkg|motion|open(jdk|vpn)|pidgin|purple|(t|wire)shark|wireguard"); do \
        env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q "$PACKAGE"; \
      done; \
    done && \
    curl -sSL -o /tmp/install_pip_pkgs.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0169-pip-installs.hook.chroot" && \
      bash /tmp/install_pip_pkgs.sh && \
    curl -sSL -o /tmp/install_firefox.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0168-firefox-install.hook.chroot" && \
      bash /tmp/install_firefox.sh && \
    curl -sSL -o /tmp/install_custom_bins.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0911-custom-binaries.hook.chroot" && \
      bash /tmp/install_custom_bins.sh && \
    curl -sSL -o /tmp/setup_skel.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0998-skel-setup.hook.chroot" && \
      bash /tmp/setup_skel.sh && \
      rm -rf /etc/skel/.bashrc.d/05_docker.bashrc \
            /etc/skel/.bashrc.d/07_keyring.bashrc \
            /etc/skel/.bashrc.d/08_vms.bashrc \
            /etc/skel/.config/mmguero.docker && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y --purge remove openjdk-11-jre-headless && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/*
