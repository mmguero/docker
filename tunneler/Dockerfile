FROM golang:1 as build

RUN go install github.com/go-bindata/go-bindata/go-bindata@latest && \
    mkdir -p /usr/src && \
    cd /usr/src && \
    git clone --recurse-submodules --shallow-submodules --single-branch --branch bare --depth 1 https://github.com/mmguero/hostyoself && \
    cd ./hostyoself && \
    go generate -v -x && \
    go build -v

# croc's release artifact names use different architecture labels for the CLI
# and croc-web. croc-web is currently released as a binary for Linux amd64
# only, so build it from the same tagged source when targeting Linux arm64.
FROM --platform=$BUILDPLATFORM golang:1-bookworm AS croc-go-toolchain
FROM --platform=$BUILDPLATFORM node:24-bookworm-slim AS croc-build

ARG TARGETARCH
ARG CROC_VERSION=latest

COPY --from=croc-go-toolchain /usr/local/go /usr/local/go
ENV PATH="/usr/local/go/bin:${PATH}"

RUN apt-get update -yqq && \
    apt-get install --no-install-recommends -yq ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    ARCH="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$ARCH" in \
      amd64) CROC_ARCH='64bit' ;; \
      arm64) CROC_ARCH='ARM64' ;; \
      *) echo "unsupported croc architecture: $ARCH" >&2; exit 1 ;; \
    esac; \
    if [ "$CROC_VERSION" = 'latest' ]; then \
      CROC_TAG="$(curl -fsSL -o /dev/null -w '%{url_effective}' https://github.com/schollz/croc/releases/latest | sed 's#^.*/##')"; \
    else \
      CROC_TAG="v${CROC_VERSION#v}"; \
    fi; \
    CROC_RELEASE_VERSION="${CROC_TAG#v}"; \
    CROC_RELEASE_BASE="https://github.com/schollz/croc/releases/download/${CROC_TAG}"; \
    mkdir -p /out; \
    CROC_ASSET="croc_v${CROC_RELEASE_VERSION}_Linux-${CROC_ARCH}.tar.gz"; \
    echo "installing ${CROC_ASSET} for ${ARCH}"; \
    curl -fsSL "${CROC_RELEASE_BASE}/${CROC_ASSET}" -o /tmp/croc.tar.gz; \
    tar -xzf /tmp/croc.tar.gz -C /out croc; \
    if [ "$ARCH" = 'amd64' ]; then \
      CROC_WEB_ASSET="croc-web_v${CROC_RELEASE_VERSION}_Linux-amd64.tar.gz"; \
      echo "installing ${CROC_WEB_ASSET}"; \
      curl -fsSL "${CROC_RELEASE_BASE}/${CROC_WEB_ASSET}" -o /tmp/croc-web.tar.gz; \
      tar -xzf /tmp/croc-web.tar.gz -C /out croc-web; \
    else \
      echo "building croc-web ${CROC_TAG} from source for ${ARCH}"; \
      mkdir -p /usr/src/croc; \
      curl -fsSL "https://codeload.github.com/schollz/croc/tar.gz/refs/tags/${CROC_TAG}" -o /tmp/croc-src.tar.gz; \
      tar -xzf /tmp/croc-src.tar.gz --strip-components=1 -C /usr/src/croc; \
      cd /usr/src/croc/web; \
      npm ci; \
      npm run embed; \
      cd /usr/src/croc; \
      CGO_ENABLED=0 GOOS=linux GOARCH="$ARCH" go build \
        -buildvcs=false -trimpath -tags netgo,osusergo \
        -ldflags='-s -w -buildid=' \
        -o /out/croc-web ./cmd/croc-web; \
    fi; \
    chmod 755 /out/croc /out/croc-web

FROM debian:trixie-slim

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
  pip3 install --break-system-packages supervisor && \
    mkdir -p /var/log/supervisor && \
  cd /tmp && \
  curl -fsSL -o /usr/bin/fflo.com "https://github.com/nuwainfo/ffl/releases/latest/download/fflo.com" && \
    chmod 644 /usr/bin/fflo.com && \
  sed -i 's/\$/$WIREPROXY_/g' /etc/wireproxy/config.env && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=croc-build --chmod=755 /out/croc /usr/bin/croc
COPY --from=croc-build --chmod=755 /out/croc-web /usr/bin/croc-web
COPY --from=build /usr/src/hostyoself/hostyoself /usr/bin/hostyoself
ADD supervisord.conf /etc/supervisord.conf
ADD --chmod=755 https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD --chmod=755 croc_relay_entrypoint.sh /usr/local/bin/croc_relay_entrypoint.sh
ADD --chmod=755 croc_web_entrypoint.sh /usr/local/bin/croc_web_entrypoint.sh
ADD bash_support_functions.sh /etc/profile.d/

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "tunneler"
ENV PGROUP "tunneler"
ENV PUSER_PRIV_DROP true

RUN groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd -M --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /nonexistant ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
    install -d -m 0700 -o ${PUSER} -g ${PGROUP} /var/lib/croc/store && \
    chmod 775 /var/log/supervisor && \
      chown root:$PGROUP /var/log/supervisor && \
    chown root:$PGROUP /bin/nc.openbsd && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /bin/nc.openbsd && \
    chown root:$PGROUP /usr/bin/socat1 && \
      setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_NET_BIND_SERVICE+eip' /usr/bin/socat1 && \
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

ARG CROC_WEB_AUTOSTART=false
ENV CROC_WEB_AUTOSTART $CROC_WEB_AUTOSTART
ARG CROC_WEB_BIND=0.0.0.0:9014
ENV CROC_WEB_BIND $CROC_WEB_BIND
ARG CROC_WEB_SITE=localhost:9014
ENV CROC_WEB_SITE $CROC_WEB_SITE
ARG CROC_WEB_RELAYS=
ENV CROC_WEB_RELAYS $CROC_WEB_RELAYS
ARG CROC_WEB_PORTS=
ENV CROC_WEB_PORTS $CROC_WEB_PORTS
ARG CROC_WEB_PASS=
ENV CROC_WEB_PASS $CROC_WEB_PASS
ARG CROC_WEB_STORE_DIR=
ENV CROC_WEB_STORE_DIR $CROC_WEB_STORE_DIR
ARG CROC_WEB_STORE_MAX_TRANSFER=1GiB
ENV CROC_WEB_STORE_MAX_TRANSFER $CROC_WEB_STORE_MAX_TRANSFER
ARG CROC_WEB_STORE_QUOTA=5GiB
ENV CROC_WEB_STORE_QUOTA $CROC_WEB_STORE_QUOTA
ARG CROC_WEB_STORE_MIN_FREE=512MiB
ENV CROC_WEB_STORE_MIN_FREE $CROC_WEB_STORE_MIN_FREE
ARG CROC_WEB_STORE_MAX_EXPIRATION=1w
ENV CROC_WEB_STORE_MAX_EXPIRATION $CROC_WEB_STORE_MAX_EXPIRATION
ARG CROC_WEB_STORE_TRUSTED_PROXIES=
ENV CROC_WEB_STORE_TRUSTED_PROXIES $CROC_WEB_STORE_TRUSTED_PROXIES
ARG CROC_WEB_UMAMI_URL=
ENV CROC_WEB_UMAMI_URL $CROC_WEB_UMAMI_URL
ARG CROC_WEB_UMAMI_ID=
ENV CROC_WEB_UMAMI_ID $CROC_WEB_UMAMI_ID
EXPOSE 9014

ARG HOSTYOSELF_AUTOSTART=false
ARG HOSTYOSELF_PORT=8010
ARG HOSTYOSELF_URL="https://hostyoself.example.org"
ARG HOSTYOSELF_GOOGLE_SITE_VER_ID=
ARG HOSTYOSELF_UMAMI_URL=
ARG HOSTYOSELF_UMAMI_ID=
ENV HOSTYOSELF_AUTOSTART $HOSTYOSELF_AUTOSTART
ENV HOSTYOSELF_PORT $HOSTYOSELF_PORT
ENV HOSTYOSELF_URL $HOSTYOSELF_URL
ENV HOSTYOSELF_GOOGLE_SITE_VER_ID $HOSTYOSELF_GOOGLE_SITE_VER_ID
ENV HOSTYOSELF_UMAMI_URL $HOSTYOSELF_UMAMI_URL
ENV HOSTYOSELF_UMAMI_ID $HOSTYOSELF_UMAMI_ID

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
