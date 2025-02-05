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

ENV ECS_RELEASES_URL "https://api.github.com/repos/elastic/ecs/releases/latest"

ENV OSD_TRANSFORM_VIS_VERSION 2.18.0

USER root

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/jdk-cacerts-auto-import.sh /usr/local/bin/jdk-cacerts-auto-import.sh
ADD https://github.com/lguillaud/osd_transform_vis/releases/download/$OSD_TRANSFORM_VIS_VERSION/transformVis-$OSD_TRANSFORM_VIS_VERSION.zip /tmp/transformVis.zip

RUN export BINARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') && \
    yum upgrade -y && \
    yum install -y curl-minimal psmisc findutils util-linux openssl jq rsync python3 python3-pip zip unzip && \
    python3 -m pip install --no-compile --no-cache-dir mmguero requests[security] && \
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
    mkdir -p /opt/ecs /data/init && \
      # download ECS (Elastic Common Schema) templates and massage them so they'll import correctly into OpenSearch
      cd /opt && \
      curl -sSL "$(curl -sSL "$ECS_RELEASES_URL" | jq '.tarball_url' | tr -d '"')" | tar xzf - -C ./ecs --strip-components 1 && \
      mv /opt/ecs/generated/elasticsearch /opt/ecs-templates && \
      mv /opt/ecs-templates/ /opt/ecs-templates-os/ && \
      find /opt/ecs-templates-os -name "*.json" -exec sed -i 's/\("type"[[:space:]]*:[[:space:]]*\)"match_only_text"/\1"text"/' "{}" \; && \
      find /opt/ecs-templates-os -name "*.json" -exec sed -i 's/\("type"[[:space:]]*:[[:space:]]*\)"constant_keyword"/\1"keyword"/' "{}" \; && \
      find /opt/ecs-templates-os -name "*.json" -exec sed -i 's/\("type"[[:space:]]*:[[:space:]]*\)"wildcard"/\1"keyword"/' "{}" \; && \
      find /opt/ecs-templates-os -name "*.json" -exec sed -i 's/\("type"[[:space:]]*:[[:space:]]*\)"flattened"/\1"nested"/' "{}" \; && \
      find /opt/ecs-templates-os -name "*.json" -exec sed -i 's/\("type"[[:space:]]*:[[:space:]]*\)"number"/\1"long"/' "{}" \; && \
      find /opt/ecs-templates-os -name "*.json" -exec bash -c "jq 'walk(if type == \"object\" and has(\"synthetic_source_keep\") then del(.synthetic_source_keep) else . end)' \"{}\" > \"{}\".new && mv \"{}\".new \"{}\"" \; && \
      # BUG: OpenSearch Security Analytics will not create a detector if the "nested" field type is in the index template/pattern
      # find /opt/ecs-templates-os -name "*.json" -exec bash -c "jq 'walk(if type == \"object\" and .type == \"nested\" then empty else . end)' \"{}\" > \"{}\".new && mv \"{}\".new \"{}\"" \; && \
      rm -rf /opt/ecs && \
    mkdir -p /var/local/ca-trust && \
    chown --silent -R ${PUSER}:${PGROUP} /usr/share/opensearch-dashboards /var/local/ca-trust /opt/ecs-templates-os /data/init && \
    chmod 755 /usr/bin/tini /usr/local/bin/*.sh && \
    yum clean all && \
    rm -rf /var/cache/yum

ADD shared-objects/templates /opt/templates
ADD shared-objects/scripts /usr/local/bin

VOLUME ["/var/local/ca-trust"]

ENTRYPOINT ["/usr/bin/tini", \
            "--", \
            "/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/usr/share/opensearch-dashboards/opensearch-dashboards-docker-entrypoint.sh"]
