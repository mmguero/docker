FROM opensearchproject/opensearch-dashboards:2.18.0

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "opensearch-dashboards"
ENV PGROUP "opensearch-dashboards"
ENV PUSER_PRIV_DROP true

ENV TERM xterm

ENV TINI_VERSION v0.19.0
ENV TINI_URL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini

ENV OSD_TRANSFORM_VIS_VERSION 2.18.0

USER root

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/jdk-cacerts-auto-import.sh /usr/local/bin/jdk-cacerts-auto-import.sh
ADD https://github.com/lguillaud/osd_transform_vis/releases/download/$OSD_TRANSFORM_VIS_VERSION/transformVis-$OSD_TRANSFORM_VIS_VERSION.zip /tmp/transformVis.zip

RUN export BINARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') && \
    yum upgrade -y && \
    yum install -y curl-minimal psmisc findutils util-linux openssl rsync python3 zip unzip && \
    curl -sSLf -o /usr/bin/tini "${TINI_URL}-${BINARCH}" && \
    usermod -a -G tty ${PUSER} && \
    cd /tmp && \
        # unzip transformVis.zip opensearch-dashboards/transformVis/opensearch_dashboards.json opensearch-dashboards/transformVis/package.json && \
        # sed -i "s/2\.16\.0/2\.17\.0/g" opensearch-dashboards/transformVis/opensearch_dashboards.json && \
        # sed -i "s/2\.16\.0/2\.17\.0/g" opensearch-dashboards/transformVis/package.json && \
        # zip transformVis.zip opensearch-dashboards/transformVis/opensearch_dashboards.json opensearch-dashboards/transformVis/package.json && \
        cd /usr/share/opensearch-dashboards/plugins && \
        /usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin install file:///tmp/transformVis.zip --allow-root && \
        rm -rf /tmp/transformVis /tmp/opensearch-dashboards && \
    mkdir -p /var/local/ca-trust && \
    chown --silent -R ${PUSER}:${PGROUP} /usr/share/opensearch-dashboards /var/local/ca-trust && \
    chmod 755 /usr/bin/tini /usr/local/bin/*.sh && \
    yum clean all && \
    rm -rf /var/cache/yum

VOLUME ["/var/local/ca-trust"]

ENTRYPOINT ["/usr/bin/tini", \
            "--", \
            "/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/share/opensearch-dashboards/opensearch-dashboards-docker-entrypoint.sh"]
