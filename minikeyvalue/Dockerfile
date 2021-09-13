FROM alpine:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/minikeyvalue'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='mmguero/minikeyvalue'
LABEL org.opencontainers.image.description='Dockerized minikeyvalue Key Value Store'

ARG GOLANG_VERSION=1.16.3
ARG MINIKEYVALUE_URL="https://github.com/geohot/minikeyvalue"

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "nginxsrv"
ENV PGROUP "nginxsrv"
ENV PUSER_PRIV_DROP true
ENV PUSER_CHOWN "/var/www/html;/var/lib/nginx;/var/log/nginx"

ENV PYTHONUNBUFFERED 1
ENV PATH /usr/local/go/bin:$PATH

RUN apk --no-cache add \
      bash \
      ca-certificates \
      curl \
      nginx \
      openssl \
      psmisc \
      shadow \
      supervisor && \
  update-ca-certificates &&  \
  apk add --no-cache --virtual .build-deps \
    gcc \
    git \
    go \
    make \
    musl-dev \
    openssl-dev && \
  apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
  cd /tmp && \
    curl -sSL -o go$GOLANG_VERSION.src.tar.gz https://dl.google.com/go/go$GOLANG_VERSION.src.tar.gz && \
    tar -C /usr/local -xzf go$GOLANG_VERSION.src.tar.gz && \
    rm -f go$GOLANG_VERSION.src.tar.gz && \
  cd /usr/local/go/src && \
    ./make.bash && \
  mkdir -p /usr/local/src && \
    git clone --depth 1 --recursive --single-branch "${MINIKEYVALUE_URL}" /usr/local/src/minikeyvalue && \
    rm -rf /usr/local/src/minikeyvalue/.git && \
  cd /usr/local/src/minikeyvalue && \
    pip3 install --no-cache-dir -r ./requirements.txt && \
    go get github.com/syndtr/goleveldb/leveldb && \
    chmod +x mkv volume && \
    ln -s /usr/local/src/minikeyvalue/mkv /usr/local/bin/ && \
    ln -s /usr/local/src/minikeyvalue/volume /usr/local/bin/ && \
  apk del .build-deps && \
  go version

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
COPY supervisord.conf /etc/supervisord.conf

RUN mkdir -p ${GOPATH}/src ${GOPATH}/bin /var/www/html /var/lib/nginx /var/log/nginx /run/nginx && \
    addgroup -g ${DEFAULT_GID} ${PGROUP} ; \
    adduser -D -H -u ${DEFAULT_UID} -h /var/www/html -s /sbin/nologin -G ${PGROUP} -g ${PUSER} ${PUSER} ; \
    addgroup ${PUSER} nginx ; \
    addgroup ${PUSER} shadow ; \
    addgroup ${PUSER} tty ; \
    addgroup nginx tty ; \
    chown -R ${PUSER}:${PGROUP} /var/www/html && \
    chown -R ${PUSER}:${PGROUP} /var/lib/nginx && \
    chown -R ${PUSER}:${PGROUP} /var/log/nginx && \
    chown -R ${PUSER}:${PGROUP} /run/nginx && \
    chmod 755 /usr/local/bin/*.sh

VOLUME /var/www/html

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]
