FROM debian:buster-slim

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/services/tunneler'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='mmguero/tunneler'
LABEL org.opencontainers.image.description='Dockerized Tunneling Services'

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ADD https://codeload.github.com/rfc1036/udptunnel/tar.gz/master /tmp/udptunnel.tar.gz

RUN  apt-get update && \
     apt-get install --no-install-recommends -qy \
      build-essential \
      ca-certificates \
      curl \
      dnsutils \
      gcc \
      iproute2 \
      iputils-ping \
      jq \
      libcap2-bin \
      net-tools \
      netcat-openbsd \
      netsniff-ng \
      openbsd-inetd \
      openssl \
      pkg-config \
      procps \
      pv \
      python3-pip \
      python3-twisted \
      socat \
      stunnel4 \
      tcpcryptd \
      tcpd && \
  cd /tmp && \
    mkdir -p ./udptunnel && \
    tar xvf ./udptunnel.tar.gz -C ./udptunnel --strip-components 1 && \
    cd ./udptunnel && \
    make && \
    make install && \
    mkdir -p /usr/local/share/udptunnel/ && \
    cp -r ./examples/* /usr/local/share/udptunnel/ && \
    cd /tmp && \
  pip3 install magic-wormhole-transit-relay supervisor && \
    mkdir -p /var/log/supervisor && \
  curl -sSL -o /tmp/croc.deb "$(curl -sSL https://api.github.com/repos/schollz/croc/releases/latest | jq -r '.assets[].browser_download_url' | grep Linux-$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')bit\.deb)" && \
    dpkg -i /tmp/croc.deb && \
  apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages --purge remove \
      build-essential \
      gcc \
      pkg-config && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD supervisord.conf /etc/supervisord.conf
ADD croc_relay_entrypoint.sh /usr/local/bin/croc_relay_entrypoint.sh

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "tunneler"
ENV PGROUP "tunneler"
ENV PUSER_PRIV_DROP true

RUN chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd -M --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /nonexistant ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
    sed -i "s/nobody/$PUSER/g" /usr/local/share/udptunnel/* && \
    chmod 775 /var/log/supervisor && \
      chown root:$PGROUP /var/log/supervisor && \
    chown root:$PGROUP /bin/nc.openbsd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /bin/nc.openbsd && \
    chown root:$PGROUP /usr/bin/socat && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/socat && \
    chown root:$PGROUP /usr/sbin/tcpd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/sbin/tcpd && \
    chown root:$PGROUP /usr/bin/openssl && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/openssl && \
    chown root:$PGROUP /usr/sbin/inetd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_IPC_LOCK+eip CAP_SYS_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/sbin/inetd && \
    chown root:$PGROUP /usr/bin/stunnel3 && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/stunnel3 && \
    chown root:$PGROUP /usr/bin/stunnel4 && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/stunnel4 && \
    chown root:$PGROUP /usr/bin/tcpcryptd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/tcpcryptd && \
    chown root:$PGROUP /usr/sbin/netsniff-ng && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_IPC_LOCK+eip CAP_SYS_ADMIN+eip' /usr/sbin/netsniff-ng && \
    chown root:$PGROUP /usr/local/sbin/udptunnel && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/local/sbin/udptunnel

ENV PATH="/usr/local/sbin:/usr/sbin:${PATH}"

WORKDIR "/tmp"

ARG WORMHOLE_AUTOSTART=false
ENV WORMHOLE_AUTOSTART $WORMHOLE_AUTOSTART
ARG WORMHOLE_PORT=4001
ENV WORMHOLE_PORT $WORMHOLE_PORT
EXPOSE $WORMHOLE_PORT

ARG CROC_PORT_LOW=9009
ARG CROC_PORT_HIGH=9013
ENV CROC_PORT_LOW $CROC_PORT_LOW
ENV CROC_PORT_HIGH $CROC_PORT_HIGH
EXPOSE $CROC_PORT_LOW-$CROC_PORT_HIGH
ARG CROC_AUTOSTART=false
ENV CROC_AUTOSTART $CROC_AUTOSTART
ARG CROC_PASS=
ENV CROC_PASS $CROC_PASS

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]
