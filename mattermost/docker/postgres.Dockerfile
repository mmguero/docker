FROM postgres:14-alpine

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/postgres'
LABEL org.opencontainers.image.description='Dockerized PostgreSQL'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "postgres"
ENV PGROUP "postgres"
ENV PUSER_PRIV_DROP true
ENV PUSER_CHOWN "/run/postgresql;/var/lib/postgresql"

ENV TERM xterm

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/bin/docker-uid-gid-setup.sh

RUN apk --no-cache add bash procps psmisc shadow && \
   chmod 755 /usr/bin/docker-uid-gid-setup.sh && \
   mv /usr/local/bin/* /usr/bin/ && \
   mv /usr/local/share/* /usr/share/ && \
   mv /usr/local/lib/* /usr/lib/ && \
   rmdir /usr/local/bin /usr/local/share /usr/local/lib && \
   ln -s /usr/bin /usr/local/bin && \
   ln -s /usr/share /usr/local/share && \
   ln -s /usr/lib /usr/local/lib

USER root

ENTRYPOINT ["/usr/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/bin/docker-entrypoint.sh", "postgres"]
