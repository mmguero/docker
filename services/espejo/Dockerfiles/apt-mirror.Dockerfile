FROM debian:buster-slim

ENV CRON "0 0 * * *"

COPY scripts/cron_env_deb.sh /usr/local/bin/
COPY config/apt-mirror_debian_bug_932112.patch /usr/local/src/

RUN apt-get update -q && \
    apt-get -y install -qq --no-install-recommends \
      apt-mirror \
      ca-certificates \
      curl \
      cron \
      gnupg2 \
      patch \
      procps \
      xz-utils && \
    bash -c "patch -p 1 --no-backup-if-mismatch < /usr/local/src/apt-mirror_debian_bug_932112.patch" && \
    apt-get -y -qq --purge remove patch && \
    apt-get -y autoremove -qq && \
    apt-get clean && \
    rm -rf /var/cache/apt/* && \
    mkdir -p /mnt/mirror/debian  && \
    chmod u+x /usr/local/bin/cron_env_deb.sh && \
    bash -c 'echo -e "${CRON} apt-mirror >/proc/1/fd/1 2>/proc/1/fd/2" | crontab -'

COPY config/mirror.list /etc/apt/mirror.list
COPY config/gpg-key-urls.list /usr/local/etc/gpg-key-urls.list

RUN grep ^http /usr/local/etc/gpg-key-urls.list | xargs -n 1 -I XXX bash -c "echo 'XXX' ; curl -fsSL 'XXX' | apt-key add - 2>/dev/null"

VOLUME ["/mnt/mirror/debian"]

ENTRYPOINT ["/usr/local/bin/cron_env_deb.sh"]
