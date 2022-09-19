FROM netboxcommunity/netbox:latest

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV LANG C.UTF-8

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "boxer"
ENV PGROUP "boxer"
ENV PUSER_PRIV_DROP true

ARG BASE_PATH=assets
ENV BASE_PATH $BASE_PATH

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD ./netbox/supervisord.conf /etc/supervisord.conf

RUN apt-get -q update && \
    apt-get -y -q --no-install-recommends upgrade && \
    apt-get install -q -y --no-install-recommends \
      iproute2 \
      iputils-ping \
      procps \
      psmisc \
      supervisor \
      tini \
      vim-tiny && \
    apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
    useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER} && \
    usermod -a -G tty ${PUSER} && \
    mkdir -p /opt/unit && \
    chown -R $PUSER:$PGROUP /etc/netbox /opt/unit /opt/netbox && \
    if [ -n "${BASE_PATH}" ] && [ "${BASE_PATH}" != "netbox" ]; then \
        mkdir /opt/netbox/netbox/$BASE_PATH && \
        mv /opt/netbox/netbox/static /opt/netbox/netbox/$BASE_PATH/static; \
    fi

ENTRYPOINT [ "/usr/bin/tini", "--", "/usr/local/bin/docker-uid-gid-setup.sh" ]

CMD ["/opt/netbox/docker-entrypoint.sh", "/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]

