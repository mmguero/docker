FROM golang:1.18-alpine AS go-build

RUN apk --no-cache add --update git gettext libintl && \
    git clone https://github.com/octeep/wireproxy.git && \
    cd ./wireproxy && \
    go build ./cmd/wireproxy

FROM alpine:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/wireproxy'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/wireproxy'
LABEL org.opencontainers.image.description='Dockerized wireproxy'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "wired"
ENV PGROUP "wired"
ENV PUSER_PRIV_DROP true

# false - read /etc/wireproxy/config from bind-mounted file
# true - generate /etc/wireproxy/config from environment variables
ENV WIREPROXY_CONFIG_FROM_ENVS false

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config.env /etc/wireproxy/config.env

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk --no-cache add \
      bash \
      libintl \
      shadow && \
    addgroup -g ${DEFAULT_GID} ${PGROUP} && \
      adduser -D -H -u ${DEFAULT_UID} -h /var/www/html -s /sbin/nologin -G ${PGROUP} -g ${PUSER} ${PUSER} && \
      chown -R ${PUSER}:${PGROUP} /etc/wireproxy && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh /usr/local/bin/entrypoint.sh

COPY --from=go-build /go/wireproxy/wireproxy /usr/bin/
COPY --from=go-build /usr/bin/envsubst /usr/bin/envsubst

VOLUME [ "/etc/wireproxy"]

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/entrypoint.sh"]
