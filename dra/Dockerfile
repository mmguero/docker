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

RUN apt-get -q update && \
    apt-get -y -q --no-install-recommends upgrade && \
    apt-get install --no-install-recommends -y -q musl musl-dev musl-tools && \
    sed -i "s/\(--release\)/\1 --offline/" Makefile && \
    uname -m && \
    if [ $(uname -m) = x86_64 ]; then export CARGO_TARGET=x86_64-unknown-linux-musl; fi && \
    if [ $(uname -m) = aarch64 ]; then export CARGO_TARGET=aarch64-unknown-linux-musl; export CC=musl-gcc; RUSTFLAGS="-C linker=aarch64-linux-gnu-gcc"; fi && \
    if [ $(uname -m) = armv7l ]; then export CARGO_TARGET=armv7-unknown-linux-musleabihf; export CC=musl-gcc; RUSTFLAGS="-C linker=arm-linux-gnueabihf-gcc"; fi && \
    if uname -m | grep -q ^arm; then export CARGO_TARGET=arm-unknown-linux-musleabihf; export CC=musl-gcc; RUSTFLAGS="-C linker=arm-linux-gnueabihf-gcc"; fi && \
    rustup target add $CARGO_TARGET && \
    make release && \
    mv -v /usr/src/dra/target/$CARGO_TARGET/release/dra /dra && \
    chmod 755 /dra

# Copy build artifact to final image

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/dra'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.documentation='https://github.com/devmatteini/dra'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/dra'
LABEL org.opencontainers.image.description='Single-binary container for devmatteini/dra'

FROM scratch

COPY --from=builder /dra /dra

ENTRYPOINT ["/dra"]