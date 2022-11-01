# syntax = docker/dockerfile:experimental

FROM rust:latest as builder

ENV USER root

RUN git clone https://github.com/devmatteini/dra /usr/src/dra

WORKDIR /usr/src/dra

RUN --security=insecure mkdir -p /root/.cargo && \
    chmod 777 /root/.cargo && \
    mount -t tmpfs none /root/.cargo && \
    make release && \
    chmod 755 /usr/src/dra/target/release/dra

FROM debian:stable-slim

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "dra"
ENV PGROUP "dra"
ENV PUSER_PRIV_DROP true

COPY --from=builder /usr/src/dra/target/release/dra /dra

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /home/${PUSER} ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
      chmod 755 /usr/local/bin/docker-uid-gid-setup.sh

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]

CMD ["/dra"]