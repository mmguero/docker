FROM ghcr.io/mmguero/xfce-base:latest

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
      bash bzip2 curl dconf-cli file git jq moreutils ca-certificates python3-pip python3-wheel python3-setuptools && \
    echo "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0168-firefox-install.hook.chroot" && \
    curl -sSL -o /tmp/install_firefox.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0168-firefox-install.hook.chroot" && \
      bash /tmp/install_firefox.sh && \
    curl -sSL -o /tmp/install_pip_pkgs.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0169-pip-installs.hook.chroot" && \
      bash /tmp/install_pip_pkgs.sh && \
    for CATEGORY in apps multimedia net; do \
      for PACKAGE in $(curl -sSL "$PACKAGE_CATEGORY_URL_PREFIX/package-lists/$CATEGORY.list.chroot"); do \
        if [ "$PACKAGE" != "brasero" ] && \
           [ "$PACKAGE" != "cdparanoia" ] && \
           [ "$PACKAGE" != "bridge-utils" ] && \
           [ "$PACKAGE" != "epiphany-browser" ] && \
           [ "$PACKAGE" != "libdvd-pkg" ] && \
           [ "$PACKAGE" != "motion" ] && \
           [ "$PACKAGE" != "openvpn" ] && \
           [ "$PACKAGE" != "tshark" ] && \
           [ "$PACKAGE" != "wireguard" ] && \
           [ "$PACKAGE" != "wireshark" ]; then \
          env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q "$PACKAGE"; \
        fi; \
      done; \
    done && \
    curl -sSL -o /tmp/install_custom_bins.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0911-custom-binaries.hook.chroot" && \
      bash /tmp/install_custom_bins.sh && \
    curl -sSL -o /tmp/setup_skel.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0998-skel-setup.hook.chroot" && \
      bash /tmp/setup_skel.sh && \
      rm -f /etc/skel/.bashrc.d/05_docker.bashrc \
            /etc/skel/.bashrc.d/07_keyring.bashrc \
            /etc/skel/.bashrc.d/08_vms.bashrc && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*