FROM golang:alpine AS go-build

RUN apk --no-cache add --update git ca-certificates && \
    update-ca-certificates && \
    git clone https://github.com/trap-bytes/403jump /403jump && \
    cd /403jump && \
    go build

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/403jump'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/403jump'
LABEL org.opencontainers.image.description='Dockerized 403jump (https://github.com/trap-bytes/403jump)'


FROM scratch

COPY --from=go-build --chmod=755 /403jump/403jump /403jump
COPY --from=go-build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/403jump"]
