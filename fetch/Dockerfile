FROM golang:alpine AS go-build

RUN apk --no-cache add --update git ca-certificates && \
    update-ca-certificates && \
    git clone https://github.com/gruntwork-io/fetch /fetch && \
    cd /fetch && \
    go build -ldflags "-X main.Version=$(git describe --tags)"

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/fetch'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/fetch'
LABEL org.opencontainers.image.description='Dockerized fetch'


FROM scratch

COPY --from=go-build --chmod=755 /fetch/fetch /fetch
COPY --from=go-build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/fetch"]
