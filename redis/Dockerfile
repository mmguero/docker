FROM redis:7-alpine

ARG DEFAULT_UID=999
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "redis"
ENV PGROUP "redis"
ENV PUSER_PRIV_DROP true

ENV TERM xterm

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk --no-cache add bash psmisc shadow tini && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    addgroup ${PUSER} tty

WORKDIR /home/${PUSER}

ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/docker-uid-gid-setup.sh" ]
