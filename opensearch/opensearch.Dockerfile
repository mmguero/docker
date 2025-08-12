FROM opensearchproject/opensearch:3.1.0

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUID $DEFAULT_UID
ENV PUSER "opensearch"
ENV PGROUP "opensearch"
ENV PUSER_CHOWN "/usr/share/opensearch/data"
ENV PUSER_PRIV_DROP true

ENV TERM xterm

ENV TINI_VERSION v0.19.0
ENV TINI_URL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini

ARG DISABLE_INSTALL_DEMO_CONFIG=true
ENV DISABLE_INSTALL_DEMO_CONFIG $DISABLE_INSTALL_DEMO_CONFIG
ENV OPENSEARCH_JAVA_HOME=/usr/share/opensearch/jdk

USER root

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/jdk-cacerts-auto-import.sh /usr/local/bin/jdk-cacerts-auto-import.sh

RUN export BINARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') && \
    yum upgrade -y && \
    yum install -y curl-minimal psmisc findutils util-linux openssl rsync python3 zip unzip && \
    curl -sSLf -o /usr/bin/tini "${TINI_URL}-${BINARCH}" && \
    usermod -a -G tty ${PUSER} && \
    echo -e 'cluster.name: "docker-cluster"\nnetwork.host: 0.0.0.0\nbootstrap.memory_lock: true\nhttp.cors.enabled: true\nhttp.cors.allow-origin: "*"\nhttp.cors.allow-methods: OPTIONS, HEAD, GET, POST, PUT, DELETE\nhttp.cors.allow-headers: "kbn-version, Origin, X-Requested-With, Content-Type, Accept, Engaged-Auth-Token Authorization"' > /usr/share/opensearch/config/opensearch.yml && \
      sed -i "s/#[[:space:]]*\([0-9]*-[0-9]*:-XX:-\(UseConcMarkSweepGC\|UseCMSInitiatingOccupancyOnly\)\)/\1/" /usr/share/opensearch/config/jvm.options && \
      sed -i "s/^[0-9][0-9]*\(-:-XX:\(+UseG1GC\|G1ReservePercent\|InitiatingHeapOccupancyPercent\)\)/$($OPENSEARCH_JAVA_HOME/bin/java -version 2>&1 | grep version | awk '{print $3}' | tr -d '\"' | cut -d. -f1)\1/" /usr/share/opensearch/config/jvm.options && \
      sed -i '/^[[:space:]]*runOpensearch.*/i /usr/local/bin/jdk-cacerts-auto-import.sh || true' /usr/share/opensearch/opensearch-docker-entrypoint.sh && \
    mkdir -p /var/local/ca-trust && \
    chown --silent -R ${PUSER}:${PGROUP} /usr/share/opensearch /var/local/ca-trust && \
    chmod 755 /usr/bin/tini /usr/local/bin/*.sh && \
    yum clean all && \
    rm -rf /var/cache/yum

VOLUME ["/var/local/ca-trust"]

ENTRYPOINT ["/usr/bin/tini", \
            "--", \
            "/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/share/opensearch/opensearch-docker-entrypoint.sh"]
