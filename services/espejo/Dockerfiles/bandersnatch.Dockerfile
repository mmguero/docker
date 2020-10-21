FROM python:3-slim

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "bandersnatch"
ENV PGROUP "bandersnatch"
ENV PUSER_PRIV_DROP true

ENV SUPERCRONIC_URL "https://github.com/aptible/supercronic/releases/download/v0.1.11/supercronic-linux-amd64"
ENV SUPERCRONIC "supercronic-linux-amd64"
ENV SUPERCRONIC_SHA1SUM "a2e2d47078a8dafc5949491e5ea7267cc721d67c"

ENV CRON "0 0 * * *"

ADD https://raw.githubusercontent.com/mmguero-personal/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN apt-get update -q && \
    apt-get -y install -qq --no-install-recommends \
      build-essential \
      curl \
      libxml2 \
      libxml2-dev \
      libxslt1-dev \
      libxslt1.1 \
      procps \
      python3-dev \
      python3-pip \
      software-properties-common \
      zlib1g \
      zlib1g-dev && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
      useradd -M --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER} && \
    pip3 install keystoneauth1 python-swiftclient bandersnatch && \
    cd /tmp && \
    apt-get -q -y --purge remove build-essential libxslt1-dev libxml2-dev python3-dev zlib1g-dev && \
      apt-get -y autoremove -qq && \
      apt-get clean && \
      rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p /mnt/mirror/pypi && \
    curl -fsSLO "$SUPERCRONIC_URL" && \
      echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - && \
      chmod +x "$SUPERCRONIC" && \
      mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
      ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic && \
    bash -c 'echo -e "${CRON} /usr/local/bin/bandersnatch mirror --force-check" > /etc/crontab'

ADD config/bandersnatch.conf /etc/

VOLUME ["/mnt/mirror/pypi"]

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/supercronic", "/etc/crontab"]