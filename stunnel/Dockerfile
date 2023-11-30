FROM vimagick/stunnel:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/stunnel'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/stunnel'
LABEL org.opencontainers.image.description='Dockerized stunnel'

RUN apk --no-cache add openssl && \
    sed -i '/cert =.*/i CAfile = /etc/stunnel/ca.crt' /entrypoint.sh
