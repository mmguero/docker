FROM pldubouilh/gossa:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.org/gossa'
LABEL org.opencontainers.image.description='Dockerized gossa'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "user"
ENV PGROUP "user"
ENV PUSER_PRIV_DROP true
USER root

ENV UID $DEFAULT_UID
ENV GID $DEFAULT_GID
ENV HOST "0.0.0.0"
ENV PORT "8001"
ENV PREFIX "/"
ENV FOLLOW_SYMLINKS "false"
ENV SKIP_HIDDEN_FILES "true"
ENV DATADIR "/shared"
ENV READONLY "false"
ENV VERBOSE "false"

ENV TERM xterm

RUN apk update --no-cache && \
    apk upgrade --no-cache && \
    apk add --no-cache bash jq procps psmisc shadow rsync tini && \
    addgroup ${PUSER} tty

ADD --chmod=755 https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/bin/docker-uid-gid-setup.sh
ADD --chmod=755 gossa.sh /usr/bin/gossa.sh

EXPOSE $PORT

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/docker-uid-gid-setup.sh"]

ENTRYPOINT ["/sbin/tini", \
            "--", \
            "/usr/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/bin/gossa.sh"]
