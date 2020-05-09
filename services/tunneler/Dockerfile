FROM debian:buster-slim

ADD https://codeload.github.com/rfc1036/udptunnel/tar.gz/master /tmp/udptunnel.tar.gz

RUN apt-get update && \
    apt-get install --no-install-recommends -qy \
      build-essential \
      curl \
      dnsutils \
      gcc \
      iproute2 \
      iputils-ping \
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
  apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages --purge remove \
      build-essential \
      gcc \
      pkg-config && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD supervisord.conf /etc/supervisord.conf

ENV TUNNEL_USER=tunneler

RUN groupadd --gid 1000 $TUNNEL_USER && \
      useradd -M --uid 1000 --gid 1000 $TUNNEL_USER && \
    sed -i "s/nobody/$TUNNEL_USER/g" /usr/local/share/udptunnel/* && \
    mkdir -p /run && \
    chown -R $TUNNEL_USER:$TUNNEL_USER /run && \
    chown root:$TUNNEL_USER /bin/nc.openbsd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /bin/nc.openbsd && \
    chown root:$TUNNEL_USER /usr/bin/socat && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/socat && \
    chown root:$TUNNEL_USER /usr/sbin/tcpd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/sbin/tcpd && \
    chown root:$TUNNEL_USER /usr/bin/openssl && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/openssl && \
    chown root:$TUNNEL_USER /usr/sbin/inetd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_IPC_LOCK+eip CAP_SYS_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/sbin/inetd && \
    chown root:$TUNNEL_USER /usr/bin/stunnel3 && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/stunnel3 && \
    chown root:$TUNNEL_USER /usr/bin/stunnel4 && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/stunnel4 && \
    chown root:$TUNNEL_USER /usr/bin/tcpcryptd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/tcpcryptd && \
    chown root:$TUNNEL_USER /usr/sbin/netsniff-ng && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_IPC_LOCK+eip CAP_SYS_ADMIN+eip' /usr/sbin/netsniff-ng && \
    chown root:$TUNNEL_USER /usr/local/sbin/udptunnel && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/local/sbin/udptunnel

ENV PATH="/usr/local/sbin:/usr/sbin:${PATH}"

USER tunneler

WORKDIR "/tmp"

ARG WORMHOLE_PORT=4001
ARG WORMHOLE_AUTOSTART=false
ENV WORMHOLE_AUTOSTART $WORMHOLE_AUTOSTART
ENV WORMHOLE_PORT $WORMHOLE_PORT
EXPOSE $WORMHOLE_PORT

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]
