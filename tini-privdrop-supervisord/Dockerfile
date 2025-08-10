FROM debian:trixie-slim

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV LANG C.UTF-8

# configure unprivileged user and runtime parameters
ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "asuka"
ENV PGROUP "asuka"
ENV PUSER_PRIV_DROP true

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD supervisord.conf /etc/supervisord.conf

RUN apt-get update && \
    apt-get install --no-install-recommends -y -q \
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
    usermod -a -G tty ${PUSER}

ENTRYPOINT [ "/usr/bin/tini", "--", "/usr/local/bin/docker-uid-gid-setup.sh" ]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]

