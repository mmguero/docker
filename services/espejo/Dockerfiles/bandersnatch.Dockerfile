FROM python:3-slim

ENV CRON "0 0 * * *"

ADD https://raw.githubusercontent.com/pypa/bandersnatch/master/requirements.txt /tmp/bandersnatch-requirements.txt

COPY scripts/cron_env_deb.sh /usr/local/bin/

RUN apt-get update -q && \
    apt-get -y install -qq --no-install-recommends \
      cron \
      software-properties-common \
      procps \
      python3-pip \
      git-core && \
    apt-get clean && \
    apt-get -y autoremove -qq && \
    rm -rf /var/cache/apt/* && \
    mkdir -p /mnt/mirror/pypi && \
    chmod u+x /usr/local/bin/cron_env_deb.sh && \
    pip install --upgrade -r /tmp/bandersnatch-requirements.txt && \
    git clone --depth=1 --recursive https://github.com/pypa/bandersnatch /tmp/bandersnatch && \
      cd /tmp/bandersnatch && \
      pip install . && \
    cd /tmp && \
    rm -rf /tmp/bandersnatch* && \
    bash -c 'echo -e "${CRON} /usr/local/bin/bandersnatch mirror --force-check >/proc/1/fd/1 2>/proc/1/fd/2" | crontab -'

COPY config/bandersnatch.conf /etc/

VOLUME ["/mnt/mirror/pypi"]

ENTRYPOINT ["/usr/local/bin/cron_env_deb.sh"]
