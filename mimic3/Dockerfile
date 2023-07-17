FROM ubuntu:22.04

ARG TARGETARCH=amd64
ARG TARGETVARIANT=

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "mimic3"
ENV PGROUP "mimic3"
ENV PUSER_PRIV_DROP true
ENV PUSER_RLIMIT_UNLOCK true

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

ARG MIMIC3_BRANCH=master
ENV MIMIC3_BRANCH $MIMIC3_BRANCH
ARG MIMIC3_VOICES_LANG=en
ENV MIMIC3_VOICES_LANG $MIMIC3_VOICES_LANG

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN echo "Dir::Cache var/cache/apt/${TARGETARCH}${TARGETVARIANT};" > /etc/apt/apt.conf.d/01cache

RUN --mount=type=cache,id=apt-run,target=/var/cache/apt \
    mkdir -p /var/cache/apt/${TARGETARCH}${TARGETVARIANT}/archives/partial \
             /usr/local/share/mycroft/mimic3 && \
    apt-get update && \
    apt-get install --yes --no-install-recommends \
        build-essential git python3 python3-dev python3-pip python3-venv \
        ca-certificates libespeak-ng1 tini vim-tiny jq && \
    sed -i "s/set[[:space:]]*compatible/set nocompatible/g" /etc/vim/vimrc.tiny && \
    groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /home/${PUSER} ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
      chsh -s /bin/bash ${PUSER} && \
    git clone --recurse-submodules --shallow-submodules --single-branch --depth 1 -b "${MIMIC3_BRANCH}" https://github.com/MycroftAI/mimic3 /tmp/mimic3 && \
    mkdir -p /home/${PUSER}/app && \
    cp -r /tmp/mimic3/opentts_abc /home/${PUSER}/app/opentts_abc && \
    cp -r /tmp/mimic3/mimic3_http /home/${PUSER}/app/mimic3_http && \
    cp -r /tmp/mimic3/mimic3_tts /home/${PUSER}/app/mimic3_tts && \
    cp /tmp/mimic3/LICENSE \
       /tmp/mimic3/MANIFEST.in \
       /tmp/mimic3/README.md \
       /tmp/mimic3/setup.py \
       /tmp/mimic3/install.sh \
       /tmp/mimic3/requirements.txt /home/${PUSER}/app/ && \
    cp -r /tmp/mimic3/voices /usr/local/share/mycroft/mimic3/voices && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages autoremove && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


WORKDIR /home/mimic3/app

# Install mimic3
RUN --mount=type=cache,id=pip-requirements,target=/root/.cache/pip \
    ./install.sh && \
    mkdir -p /home/${PUSER}/.local/share/mycroft/mimic3/voices && \
    /home/${PUSER}/app/.venv/bin/python3 -m mimic3_tts.download 2>/dev/null | \
        jq -r '. |= keys | .[]' | sort | grep "^${MIMIC3_VOICES_LANG}" | \
        xargs -r -L 1 /home/${PUSER}/app/.venv/bin/python3 -m mimic3_tts.download --output-dir /home/${PUSER}/.local/share/mycroft/mimic3/voices && \
    chown -R ${PUSER}:${PUSER} /home/${PUSER} && \
    mkdir -p /root/.local/share/mycroft/mimic3 && \
        ln -s /home/${PUSER}/.local/share/mycroft/mimic3/voices /root/.local/share/mycroft/mimic3/voices && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh

WORKDIR /home/mimic3/app

EXPOSE 59125

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/home/mimic3/app/.venv/bin/python3", "-m", "mimic3_http"]
