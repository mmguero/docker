FROM golang:alpine AS go-build

RUN apk --no-cache add --update git && \
    git clone https://github.com/boringproxy/boringproxy.git /boringproxy && \
    cd /boringproxy/cmd/boringproxy && \
    go build -ldflags "-X main.Version=$(git describe --tags)"

FROM alpine:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/boringproxy'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.org/boringproxy'
LABEL org.opencontainers.image.description='Dockerized boringproxy'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "boring"
ENV PGROUP "boring"
ENV PUSER_PRIV_DROP true

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
COPY --from=go-build --chmod=755 /boringproxy/cmd/boringproxy/boringproxy /boringproxy

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk --no-cache add --update \
      bash \
      ca-certificates \
      libcap \
      openssh-client \
      openssh-server \
      openssl \
      shadow && \
    addgroup -g ${DEFAULT_GID} ${PGROUP} && \
      adduser -D -u ${DEFAULT_UID} -h /home/${PUSER} -s /sbin/nologin -G ${PGROUP} -g ${PUSER} ${PUSER} && \
    mkdir -p /home/${PUSER}/.ssh /home/${PUSER}/certs /home/${PUSER}/db && \
      chmod 700 /home/${PUSER}/.ssh /home/${PUSER}/certs /home/${PUSER}/db && \
      touch /home/${PUSER}/.ssh/authorized_keys && \
      chmod 600 /home/${PUSER}/.ssh/authorized_keys && \
    chown ${PUSER}:${PGROUP} /home/${PUSER}/.ssh /home/${PUSER}/.ssh/authorized_keys && \
    chown root:${PGROUP} /boringproxy && \
      setcap 'CAP_NET_BIND_SERVICE+eip' /boringproxy && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh

WORKDIR /home/${PUSER}/db

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh", "/boringproxy"]
