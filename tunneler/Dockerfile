FROM debian:bookworm-slim

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/tunneler'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.org/tunneler'
LABEL org.opencontainers.image.description='Dockerized Tunneling Services'

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

COPY --from=ghcr.io/mmguero-dev/gostatic --chmod=755 /goStatic /usr/bin/goStatic
COPY --from=ghcr.io/mmguero/wireproxy --chmod=755 /usr/bin/wireproxy /usr/bin/wireproxy
COPY --from=ghcr.io/mmguero/wireproxy --chmod=644 /etc/wireproxy/config.env /etc/wireproxy/config.env

RUN  apt-get update -yqq && \
     apt-get install --no-install-recommends -yq \
      ca-certificates \
      curl \
      dnsutils \
      iproute2 \
      iptables \
      iputils-ping \
      jo \
      jq \
      libcap2-bin \
      net-tools \
      netcat-openbsd \
      netsniff-ng \
      openbsd-inetd \
      openssl \
      procps \
      pv \
      python3-pip \
      python3-twisted \
      socat \
      stunnel4 \
      tcpd \
      tree \
      && \
  pip3 install --break-system-packages magic-wormhole-transit-relay supervisor && \
    mkdir -p /var/log/supervisor && \
  cd /tmp && \
  curl -fsSL "$(curl -sSL https://api.github.com/repos/schollz/croc/releases/latest | jq -r '.assets[].browser_download_url' | grep Linux-$(uname -m | sed 's/x86_64/64bit/;s/i[3-6]86/32bit/;s/aarch/ARM/')\.tar\.gz)" | tar -xzf - croc && \
    chmod 755 ./croc && \
    mv ./croc /usr/bin && \
  curl -sSL -o /tmp/hostyoself.deb "$(curl -sSL https://api.github.com/repos/schollz/hostyoself/releases/latest | jq -r '.assets[].browser_download_url' | grep Linux-$(uname -m | sed 's/x86_64/64bit/;s/i[3-6]86/32bit/;s/aarch/ARM/')\.deb)" && \
    dpkg -i /tmp/hostyoself.deb && \
  sed -i 's/\$/$WIREPROXY_/g' /etc/wireproxy/config.env && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD supervisord.conf /etc/supervisord.conf
ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD croc_relay_entrypoint.sh /usr/local/bin/croc_relay_entrypoint.sh
ADD bash_support_functions.sh /etc/profile.d/

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
    chown root:$PGROUP /usr/sbin/netsniff-ng && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_IPC_LOCK+eip CAP_SYS_ADMIN+eip' /usr/sbin/netsniff-ng && \
    chown root:$PGROUP /usr/bin/wireproxy && \
      setcap 'CAP_NET_BIND_SERVICE+eip' /usr/bin/wireproxy

ENV PATH="/usr/local/sbin:/usr/sbin:${PATH}"

WORKDIR "/tmp"

ARG WORMHOLE_AUTOSTART=false
ENV WORMHOLE_AUTOSTART $WORMHOLE_AUTOSTART
ARG WORMHOLE_PORT=4001
ENV WORMHOLE_PORT $WORMHOLE_PORT
EXPOSE $WORMHOLE_PORT

ARG CROC_PORT_LOW=9009
ARG CROC_PORT_HIGH=9013
ARG CROC_PORT_NON_SEQUENTIAL=false
ENV CROC_PORT_LOW $CROC_PORT_LOW
ENV CROC_PORT_HIGH $CROC_PORT_HIGH
ENV CROC_PORT_NON_SEQUENTIAL $CROC_PORT_NON_SEQUENTIAL
EXPOSE $CROC_PORT_LOW-$CROC_PORT_HIGH
ARG CROC_AUTOSTART=false
ENV CROC_AUTOSTART $CROC_AUTOSTART
ARG CROC_PASS=
ENV CROC_PASS $CROC_PASS

ARG HOSTYOSELF_AUTOSTART=false
ARG HOSTYOSELF_PORT=8010
ARG HOSTYOSELF_URL="https://hostyoself.example.org"
ENV HOSTYOSELF_AUTOSTART $HOSTYOSELF_AUTOSTART
ENV HOSTYOSELF_PORT $HOSTYOSELF_PORT
ENV HOSTYOSELF_URL $HOSTYOSELF_URL

ARG WIREPROXY_AUTOSTART=false
ENV WIREPROXY_AUTOSTART $WIREPROXY_AUTOSTART
ARG WIREPROXY_ALLOWED_IPS=
ARG WIREPROXY_CONF=/etc/wireproxy/config.env
ARG WIREPROXY_DNS=
ARG WIREPROXY_ENDPOINT_ADDRESS=
ARG WIREPROXY_ENDPOINT_KEY=
ARG WIREPROXY_KEEPALIVE=0
ARG WIREPROXY_LOCAL_ADDRESS=
ARG WIREPROXY_LOCAL_KEY=
ARG WIREPROXY_MTU=1420
ARG WIREPROXY_PRESHARED_KEY=
ARG WIREPROXY_SOCKS_ADDRESS=
ENV WIREPROXY_ALLOWED_IPS $WIREPROXY_ALLOWED_IPS
ENV WIREPROXY_CONF $WIREPROXY_CONF
ENV WIREPROXY_DNS $WIREPROXY_DNS
ENV WIREPROXY_ENDPOINT_ADDRESS $WIREPROXY_ENDPOINT_ADDRESS
ENV WIREPROXY_ENDPOINT_KEY $WIREPROXY_ENDPOINT_KEY
ENV WIREPROXY_KEEPALIVE $WIREPROXY_KEEPALIVE
ENV WIREPROXY_LOCAL_ADDRESS $WIREPROXY_LOCAL_ADDRESS
ENV WIREPROXY_LOCAL_KEY $WIREPROXY_LOCAL_KEY
ENV WIREPROXY_MTU $WIREPROXY_MTU
ENV WIREPROXY_PRESHARED_KEY $WIREPROXY_PRESHARED_KEY
ENV WIREPROXY_SOCKS_ADDRESS $WIREPROXY_SOCKS_ADDRESS


ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]
