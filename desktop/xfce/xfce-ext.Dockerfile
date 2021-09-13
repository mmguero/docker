FROM ghcr.io/mmguero/xfce:latest

#  -v /var/run/libvirt/:/var/run/libvirt/ \
#  -v /var/run/docker.sock:/var/run/docker.sock \
#  --network host

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/desktop/xfce'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/xfce-ext:latest'
LABEL org.opencontainers.image.description='Dockerized XFCE with tools for binding docker and libvirt access'

RUN cd /tmp && \
    mkdir -p ./docker_static && \
    curl -sSL "https://download.docker.com/linux/static/stable/$(uname -m)/$(curl -sSL "https://download.docker.com/linux/static/stable/$(uname -m)/" | egrep '^<a href="docker-[0-9]' | sort --version-sort | tail -n 1 | sed 's/.*">//' | sed 's/<\/.*//')" | tar xzvf - -C ./docker_static --strip-components 1 && \
    cp -v /tmp/docker_static/docker /usr/local/bin/docker && \
    chmod 755 /usr/local/bin/docker && \
    python3 -m pip install docker-compose && \
    curl -o /usr/local/bin/podman-compose https://raw.githubusercontent.com/containers/podman-compose/devel/podman_compose.py && \
    chmod 755 /usr/local/bin/podman-compose && \
  apt-get -q update && \
  env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y -q \
    automake \
    autotools-dev \
    bison \
    build-essential \
    curl \
    dnsmasq-base \
    ebtables \
    gir1.2-spiceclientgtk-3.0 \
    libbz2-dev \
    libffi-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libguestfs-tools \
    libharfbuzz-dev \
    libjpeg-dev \
    liblcms2-dev \
    liblzma-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libopenjp2-7-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libtiff5-dev \
    libvirt-clients \
    libvirt-dev \
    libvirt0 \
    libwebp-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libxslt-dev \
    llvm \
    make \
    openssh-client \
    openssh-sftp-server \
    podman \
    qemu \
    qemu-system \
    qemu-utils \
    rsync \
    ruby-bundler \
    ruby-dev \
    ruby-libvirt \
    virt-manager \
    virtinst \
    wget \
    xz-utils \
    zlib1g-dev && \
  curl -o /tmp/vagrant.deb "https://releases.hashicorp.com$(curl -fsL "https://releases.hashicorp.com$(curl -fsL "https://releases.hashicorp.com/vagrant" | grep 'href="/vagrant/' | head -n 1 | grep -o '".*"' | tr -d '"' )" | grep "x86_64\.deb" | head -n 1 | grep -o 'href=".*"' | sed 's/href=//' | tr -d '"')" && \
    env DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/vagrant.deb && \
  env DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/*

ARG VAGRANT_DEFAULT_PROVIDER="libvirt"
ARG LIBVIRT_DEFAULT_URI="qemu:///system"

ENV VAGRANT_DEFAULT_PROVIDER $VAGRANT_DEFAULT_PROVIDER
ENV LIBVIRT_DEFAULT_URI $LIBVIRT_DEFAULT_URI

ARG DEFAULT_VAGRANT_PLUGINS=vagrant-libvirt,vagrant-mutate,vagrant-reload,vagrant-scp,vagrant-sshfs

RUN mkdir -p /etc/skel/.vagrant.d/; \
    for plugin in $(echo "$DEFAULT_VAGRANT_PLUGINS" | sed "s/,/ /g"); \
    do \
      env CONFIGURE_ARGS="with-libvirt-include=/usr/include/libvirt with-libvirt-lib=/usr/lib" VAGRANT_HOME="/etc/skel/.vagrant.d" vagrant plugin install ${plugin} ; \
    done; \
    for dir in boxes data tmp; \
    do \
      touch /etc/skel/.vagrant.d/.remove; \
    done