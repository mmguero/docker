# Fetch the vendor with the builder platform to avoid QEMU issues, see:
# - https://github.com/docker/buildx/issues/395
# - https://github.com/rust-lang/cargo/issues/8719#issuecomment-932084513
# - https://github.com/jdrouet/jolimail/blob/main/multiarch.Dockerfile#L33

FROM --platform=$BUILDPLATFORM rust:latest AS rust-sources

ENV USER root

WORKDIR /usr/src/dra

RUN cargo init && \
    git clone https://github.com/devmatteini/dra /tmp/dra && \
    rm -rf /usr/src/dra/src && \
    mv /tmp/dra/* /usr/src/dra && \
    mkdir -p /usr/src/dra/.cargo && \
    cargo vendor > /usr/src/dra/.cargo/config && \
    rm -rf /tmp/dra

# Build "offline" with the .cargo and vendor directories from builder platform

FROM rust:latest as builder

ENV USER root

RUN git clone https://github.com/devmatteini/dra /usr/src/dra

COPY --from=rust-sources /usr/src/dra/.cargo /usr/src/dra/.cargo
COPY --from=rust-sources /usr/src/dra/vendor /usr/src/dra/vendor

WORKDIR /usr/src/dra

RUN sed "s/\(--release\)/\1 --offline/" Makefile && \
    make release && \
    chmod 755 /usr/src/dra/target/release/dra

# Copy build artifact to final image

FROM debian:bullseye-slim

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

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh", "/dra"]
