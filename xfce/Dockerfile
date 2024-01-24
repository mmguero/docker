# x11docker/xfce
#
# Run XFCE desktop in docker.
# Use x11docker to run image.
# Get x11docker from github:
#   https://github.com/mviereck/x11docker
#
# Examples:
#   - Run desktop:
#       x11docker --desktop x11docker/xfce
#   - Run single application:
#       x11docker x11docker/xfce thunar
#
# Options:
# Persistent home folder stored on host with   --home
# Shared host folder with                      --share DIR
# Hardware acceleration with option            --gpu
# Clipboard sharing with option                --clipboard
# ALSA sound support with option               --alsa
# Pulseaudio sound support with option         --pulseaudio
# Language setting with                        --lang [=$LANG]
# Printing over CUPS with                      --printer
# Webcam support with                          --webcam
#
# Look at x11docker --help for further options.

FROM debian:bookworm as base

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/xfce'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/xfce:base'
LABEL org.opencontainers.image.description='Dockerized XFCE with my own special blend of herbs and spices'

RUN apt-get update && apt-mark hold iptables && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      dbus-x11 \
      psmisc \
      xdg-utils \
      x11-xserver-utils \
      x11-utils && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      xfce4 && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libgtk-3-bin \
      libpulse0 \
      mousepad \
      xfce4-notifyd \
      xfce4-taskmanager \
      xfce4-terminal && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      xfce4-battery-plugin \
      xfce4-clipman-plugin \
      xfce4-cpufreq-plugin \
      xfce4-cpugraph-plugin \
      xfce4-diskperf-plugin \
      xfce4-datetime-plugin \
      xfce4-fsguard-plugin \
      xfce4-genmon-plugin \
      xfce4-indicator-plugin \
      xfce4-netload-plugin \
      xfce4-places-plugin \
      xfce4-sensors-plugin \
      xfce4-smartbookmark-plugin \
      xfce4-systemload-plugin \
      xfce4-timer-plugin \
      xfce4-verve-plugin \
      xfce4-weather-plugin \
      xfce4-whiskermenu-plugin && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libxv1 \
      mesa-utils \
      mesa-utils-extra && \
    sed -i 's%<property name="ThemeName" type="string" value="Xfce"/>%<property name="ThemeName" type="string" value="Raleigh"/>%' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# disable xfwm4 compositing if X extension COMPOSITE is missing and no config file exists
RUN Configfile="~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" && \
echo "#! /bin/bash\n\
xdpyinfo | grep -q -i COMPOSITE || {\n\
  echo 'x11docker/xfce: X extension COMPOSITE is missing.\n\
Window manager compositing will not work.\n\
If you run x11docker with option --nxagent,\n\
you might want to add option --composite.' >&2\n\
  [ -e $Configfile ] || {\n\
    mkdir -p $(dirname $Configfile)\n\
    echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<channel name=\"xfwm4\" version=\"1.0\">\n\
\n\
  <property name=\"general\" type=\"empty\">\n\
    <property name=\"use_compositing\" type=\"bool\" value=\"false\"/>\n\
  </property>\n\
</channel>\n\
' > $Configfile\n\
  }\n\
}\n\
startxfce4\n\
" > /usr/local/bin/start && \
chmod +x /usr/local/bin/start

CMD start

FROM base as plus

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/xfce'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/xfce:latest'
LABEL org.opencontainers.image.description='Dockerized XFCE with my own special blend of herbs and spices'

# liberally steal some package lists and config scripts from my live USB image setup one of my other repos
#   https://github.com/mmguero/deblive/
ARG PACKAGE_CATEGORY_URL_PREFIX="https://raw.githubusercontent.com/mmguero/deblive/master/bookworm/config"
ARG GITHUB_TOKEN

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/debian-bookworm-sources.list /etc/apt/sources.list

RUN rm -f /etc/apt/sources.list.d/debian.sources && \
    apt-get -q update && \
    env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
      bash \
      bc \
      bzip2 \
      build-essential \
      ca-certificates \
      ca-certificates-java \
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
      jo \
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
      python3-dev \
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
      for PACKAGE in $(curl -sSL "$PACKAGE_CATEGORY_URL_PREFIX/package-lists/$CATEGORY.list.chroot" | grep -Pvi "abiword|audac(ious|ity)|brasero|bridge-utils|cdparanoia|cheese|firefox|gimp|gnumeric|handbrake|libdvd-pkg|motion|open(jdk|vpn)|pidgin|purple|resolvconf|sshuttle|(t|wire)shark|ufw|wireguard"); do \
        env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q "$PACKAGE"; \
      done; \
    done && \
    install -d -m 0755 /etc/apt/keyrings && \
      curl -fsSL -o /etc/apt/keyrings/packages.mozilla.org.asc https://packages.mozilla.org/apt/repo-signing-key.gpg && \
      gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); print "\n"$0"\n"}' && \
      echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" > /etc/apt/sources.list.d/mozilla.list && \
      apt-get -q update && \
      env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q firefox && \
    curl -sSL -o /tmp/sublime.deb "$(curl -sSL "https://www.sublimetext.com/3"|grep "sublime-text_build-3.*$(dpkg --print-architecture).deb\"" | sed 's/[[:space:]]*<a href="//' | sed 's/">.*//')" && \
      env DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/sublime.deb && \
    curl -sSL -o /tmp/install_pip_pkgs.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0169-pip-installs.hook.chroot" && \
      bash /tmp/install_pip_pkgs.sh && \
    curl -sSL -o /tmp/install_custom_bins.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0911-custom-binaries.hook.chroot" && \
      ( [ -n "${GITHUB_TOKEN}" ] && export GITHUB_TOKEN || true ) && \
      bash /tmp/install_custom_bins.sh && \
    curl -sSL -o /tmp/setup_skel.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0998-skel-setup.hook.chroot" && \
      bash /tmp/setup_skel.sh && \
      rm -rf /etc/skel/.bashrc.d/07_keyring.bashrc \
             /etc/skel/.config/mmguero.docker && \
    git clone https://github.com/asdf-vm/asdf.git /etc/skel/.asdf && \
    curl -sSL -o /tmp/localepurge.sh "$PACKAGE_CATEGORY_URL_PREFIX/hooks/normal/0992-localepurge.hook.chroot" && \
      bash /tmp/localepurge.sh && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y --purge remove openjdk-17-jre-headless python3-dev build-essential && \
    env DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/*
