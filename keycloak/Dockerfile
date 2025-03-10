FROM registry.access.redhat.com/ubi9 AS ubi-micro-build

RUN mkdir -p /mnt/rootfs && \
    dnf install --nodocs -y --releasever 9 --setopt install_weak_deps=false --installroot /mnt/rootfs \
      curl-minimal \
      postgresql \
      procps-ng \
      psmisc \
      rsync \
      util-linux \
      which && \
    dnf --installroot /mnt/rootfs clean all && \
    rpm --root /mnt/rootfs -e --nodeps setup

FROM quay.io/keycloak/keycloak:26.1 AS builder

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_RELATIVE_PATH=/
ENV KC_DB=postgres

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.1

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/keycloak'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.org/keycloak'
LABEL org.opencontainers.image.description='Dockerized Keycloak'


ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUID $DEFAULT_UID
ENV PUSER "keycloak"
ENV PGROUP "keycloak"
ENV PUSER_PRIV_DROP true
# This is to handle an issue when running with rootless podman and
#   "userns_mode: keep-id". It seems that anything defined as a VOLUME
#   in the Dockerfile is getting set with an ownership of 999:999.
#   This is to override that, although I'm not yet sure if there are
#   other implications. See containers/podman#23347.
ENV PUSER_CHOWN "/var/local/ca-trust"
USER root

ENV TERM xterm

ENV TINI_VERSION v0.19.0
ENV TINI_URL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini

COPY --from=ubi-micro-build /mnt/rootfs /
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Remove the opensearch-security plugin - Malcolm manages authentication and encryption via NGINX reverse proxy
# Remove the performance-analyzer plugin - Reduce resources in docker image
RUN export BINARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') && \
  mkdir -p /var/local/ca-trust && \
    chown -R $PUSER:$PGROUP /var/local/ca-trust && \
  curl -sSLf -o /usr/bin/tini "${TINI_URL}-${BINARCH}" && \
    chmod +x /usr/bin/tini

ADD --chmod=755 https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD --chmod=755 docker-entrypoint.sh /usr/local/bin/

# see PUSER_CHOWN comment above
VOLUME ["/var/local/ca-trust"]

ENTRYPOINT ["/usr/bin/tini", \
            "--", \
            "/usr/local/bin/docker-uid-gid-setup.sh", \
            "/usr/local/bin/docker-entrypoint.sh", \
            "/opt/keycloak/bin/kc.sh"]

CMD ["start"]
