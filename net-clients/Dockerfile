FROM alpine:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/net-clients'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.top/net-clients'
LABEL org.opencontainers.image.description='Dockerized Network Client Utilities'

RUN apk add --no-cache \
        autossh \
        bash \
        bat \
        busybox-extras \
        croc \
        curl \
        file \
        git \
        iproute2 \
        jq \
        moreutils \
        mosh \
        netcat-openbsd \
        openssh-client \
        psmisc \
        pv \
        rclone \
        rsync \
        shadow \
        socat \
        stunnel \
        w3m \
        wget \
        whois \
        yq

ENTRYPOINT /bin/bash
