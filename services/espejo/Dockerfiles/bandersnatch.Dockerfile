FROM python:3-slim

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "bandersnatch"
ENV PGROUP "bandersnatch"
ENV PUSER_CHOWN "/pypidb"
ENV PUSER_PRIV_DROP true

ENV SUPERCRONIC_URL "https://github.com/aptible/supercronic/releases/download/v0.1.11/supercronic-linux-amd64"
ENV SUPERCRONIC "supercronic-linux-amd64"
ENV SUPERCRONIC_SHA1SUM "a2e2d47078a8dafc5949491e5ea7267cc721d67c"

ARG LATEST_RELEASE="0"
ARG BASE_CONF_FILE="/etc/bandersnatch_base.conf"
ARG BLACKLIST_PACKAGE_FILE="/etc/bandersnatch_blacklist_packages.conf"
ARG BLACKLIST_REGEX_FILE="/etc/bandersnatch_blacklist_packages_regex.conf"
ARG BLACKLIST_PLATFORMS="macos;windows;freebsd"
ARG BLACKLIST_KEYWORDS=""
# see https://pypi.org/classifiers/
ARG BLACKLIST_CLASSIFIERS=""
ARG WHITELIST_PACKAGE_FILE="/etc/bandersnatch_whitelist_packages.conf"
ARG PYPI_PROJECT_DB="/pypidb/pypi_cache.db"
ARG PYPI_OFFLINE=false
ARG PYPI_REQ_THREADS=1

ENV LATEST_RELEASE $LATEST_RELEASE
ENV BASE_CONF_FILE $HOST_BASE_CONF_FILE
ENV BLACKLIST_PACKAGE_FILE $BLACKLIST_PACKAGE_FILE
ENV BLACKLIST_REGEX_FILE $BLACKLIST_REGEX_FILE
ENV BLACKLIST_PLATFORMS $BLACKLIST_PLATFORMS
ENV BLACKLIST_KEYWORDS $BLACKLIST_KEYWORDS
ENV BLACKLIST_CLASSIFIERS $BLACKLIST_CLASSIFIERS
ENV WHITELIST_PACKAGE_FILE $WHITELIST_PACKAGE_FILE
ENV PYPI_PROJECT_DB $PYPI_PROJECT_DB
ENV PYPI_OFFLINE $PYPI_OFFLINE
ENV PYPI_REQ_THREADS $PYPI_REQ_THREADS

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
      libzmq5 \
      moreutils \
      procps \
      python3-dev \
      python3-pip \
      software-properties-common \
      vim-tiny \
      zlib1g \
      zlib1g-dev && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
      useradd -M --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PGROUP} && \
    python3 -m pip install --no-cache-dir beautifulsoup4 install keystoneauth1 python-swiftclient bandersnatch pyzmq && \
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
    bash -c 'echo -e "${CRON} /usr/local/bin/bandersnatch.sh mirror --force-check" > /etc/crontab'

ADD config/bandersnatch.conf /etc/
ADD scripts/pypi_filter.py /usr/local/bin/
ADD scripts/bandersnatch.sh /usr/local/bin/

RUN mkdir /pypidb && \
    chown ${PUSER}:${PGROUP} /pypidb && \
    chown ${PUSER}:${PGROUP} /etc/bandersnatch.conf && \
    chmod 755 /usr/local/bin/pypi_filter.py && \
    chmod 755 /usr/local/bin/bandersnatch.sh

VOLUME ["/mnt/mirror/pypi"]
VOLUME ["/pypidb"]

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/local/bin/supercronic", "/etc/crontab"]