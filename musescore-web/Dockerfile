# syntax=docker/dockerfile:1

ARG MUSESCORE_VERSION=4.7.7
ARG MUSESCORE_BUILD=261109195
ARG MUSESCORE_URL_BASE=https://cdn.jsdelivr.net/musescore

###############################################################################
# fetch and unpack the AppImage (no FUSE in containers, so extract it instead)
FROM debian:trixie-slim AS musescore-fetch

ARG TARGETARCH
ARG MUSESCORE_VERSION
ARG MUSESCORE_BUILD
ARG MUSESCORE_URL_BASE

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/musescore

RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) MS_ARCH=x86_64 ;; \
      arm64) MS_ARCH=aarch64 ;; \
      *) echo "unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    MS_FILE="MuseScore-Studio-${MUSESCORE_VERSION}.${MUSESCORE_BUILD}-${MS_ARCH}.AppImage"; \
    curl -fsSL --retry 3 -o MuseScore.AppImage \
      "${MUSESCORE_URL_BASE}/v${MUSESCORE_VERSION}/${MS_FILE}"; \
    chmod +x MuseScore.AppImage; \
    ./MuseScore.AppImage --appimage-extract >/dev/null; \
    mv squashfs-root /opt/musescore; \
    chmod -R a+rX /opt/musescore; \
    rm -f MuseScore.AppImage

###############################################################################
FROM jlesage/baseimage-gui:debian-13-v4

ARG MUSESCORE_VERSION

ENV APP_NAME="MuseScore"
ENV WEB_AUDIO=1

# Qt/xcb runtime bits the AppImage expects the host to provide,
# plus Mesa so Qt Quick can render with llvmpipe (no GPU in here)
RUN add-pkg \
      ca-certificates \
      fonts-dejavu-core \
      libasound2-plugins \
      libasound2t64 \
      libcom-err2 \
      libdbus-1-3 \
      libegl1 \
      libfontconfig1 \
      libfreetype6 \
      libgl1 \
      libgl1-mesa-dri \
      libglib2.0-0t64 \
      libice6 \
      libopengl0 \
      libpipewire-0.3-0t64 \
      libpulse0 \
      libsm6 \
      libx11-xcb1 \
      libxcb-cursor0 \
      libxcb-icccm4 \
      libxcb-image0 \
      libxcb-keysyms1 \
      libxcb-randr0 \
      libxcb-render-util0 \
      libxcb-shape0 \
      libxcb-xinerama0 \
      libxcb-xkb1 \
      libxi6 \
      libxkbcommon-x11-0 \
      libxkbcommon0 \
      libxrender1

COPY --from=musescore-fetch /opt/musescore /opt/musescore

# fail the build now (with a list) if the main binary has unresolved libraries,
# rather than finding out when the web UI shows a blank screen
RUN set -eu; \
    MS_BIN="$(find /opt/musescore/bin -maxdepth 1 -type f -name 'mscore*' | head -n 1)"; \
    test -n "${MS_BIN}"; \
    MISSING="$(LD_LIBRARY_PATH=/opt/musescore/lib ldd "${MS_BIN}" | grep 'not found' || true)"; \
    if [ -n "${MISSING}" ]; then echo "${MS_BIN} missing libraries:" >&2; echo "${MISSING}" >&2; exit 1; fi

COPY --chmod=644 asound.conf /etc/asound.conf
COPY --chmod=755 startapp.sh /startapp.sh

LABEL org.opencontainers.image.title="musescore-web" \
      org.opencontainers.image.version="${MUSESCORE_VERSION}"
