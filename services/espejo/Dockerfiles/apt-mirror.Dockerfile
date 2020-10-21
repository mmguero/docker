FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "apt-mirror"
ENV PGROUP "apt-mirror"
ENV PUSER_PRIV_DROP true

ENV SUPERCRONIC_URL "https://github.com/aptible/supercronic/releases/download/v0.1.11/supercronic-linux-amd64"
ENV SUPERCRONIC "supercronic-linux-amd64"
ENV SUPERCRONIC_SHA1SUM "a2e2d47078a8dafc5949491e5ea7267cc721d67c"

ENV CRON "0 0 * * *"

ADD https://raw.githubusercontent.com/mmguero-personal/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD config/apt-mirror_debian_bug_932112.patch /usr/local/src/

RUN apt-get update -q && \
    apt-get -y install -qq --no-install-recommends \
      apt-mirror \
      ca-certificates \
      curl \
      gnupg2 \
      patch \
      procps \
      xz-utils && \
    bash -c "patch -p 1 --no-backup-if-mismatch < /usr/local/src/apt-mirror_debian_bug_932112.patch" && \
    apt-get -y -qq --purge remove patch && \
    apt-get -y autoremove -qq && \
    apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /mnt/mirror/debian  && \
  chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
  curl -fsSLO "$SUPERCRONIC_URL" && \
    echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - && \
    chmod +x "$SUPERCRONIC" && \
    mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
    ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic && \
  bash -c 'echo -e "${CRON} apt-mirror" > /etc/crontab'

ADD config/mirror.list /etc/apt/mirror.list
ADD config/gpg-key-urls.list /usr/local/etc/gpg-key-urls.list

RUN grep ^http /usr/local/etc/gpg-key-urls.list | xargs -n 1 -I XXX bash -c "echo 'XXX' ; curl -fsSL 'XXX' | apt-key add - 2>/dev/null"

VOLUME ["/mnt/mirror/debian"]

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/supercronic", "/etc/crontab"]
