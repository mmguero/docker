# Zeek and Spicy

# use the handy-dandy zeek-docker.sh or manually as per these examples

# Monitor a local network interface with Zeek:
#
#   docker run --rm \
#     -v "$(pwd):/zeek-logs" \
#     --network host \
#     --cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=IPC_LOCK \
#     mmguero/zeek:latest \
#     zeekcap -i enp6s0 local

# Analyze a PCAP file with Zeek:
#
#   docker run --rm \
#     -v "$(pwd):/zeek-logs" \
#     -v "/path/containing/pcap:/data:ro" \
#     mmguero/zeek:latest \
#     zeek -C -r /data/foobar.pcap local

# Use a custom policy:
#
#   docker run --rm \
#     -v "$(pwd):/zeek-logs" \
#     -v "/path/containing/pcap:/data:ro" \
#     -v "/path/containing/policy/local-example.zeek:/opt/zeek/share/zeek/site/local.zeek:ro" \
#     mmguero/zeek:latest \
#     zeek -C -r /data/foobar.pcap local

FROM debian:buster-slim AS build

# build stage for Zeek and Spicy

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ENV CCACHE_DIR "/var/spool/ccache"
ENV CCACHE_COMPRESS 1
ENV SPICY_DIR "/opt/spicy"
ENV SPICY_BRANCH "master"
ENV SRC_BASE_DIR "/usr/local/src"
ENV ZEEK_DIR "/opt/zeek"
ENV ZEEK_VERSION "3.0.12"

ENV PATH "${ZEEK_DIR}/bin:${CMAKE_DIR}/bin:${PATH}"

# configure system for build
RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian testing main" >> /etc/apt/sources.list && \
    echo "Package: bison,build-essential,cmake,python3,python3-dev,python3-pip,python3-setuptools,python3-wheel\\nPin: release a=testing\\nPin-Priority: 800\\n\\nPackage: *\\nPin: release a=stable\\nPin-Priority: 700\\n\\nPackage: *\\nPin: release a=buster-backports\\nPin-Priority: 650\\n\\n\\nPackage: *\\nPin: release a=testing\\nPin-Priority: 600\\n" > /etc/apt/preferences.d/pin && \
    echo 'APT::Default-Release "buster";' >> /etc/apt/apt.conf && \
      apt-get -q update && \
      apt-get install -q -y --no-install-recommends gnupg2 curl ca-certificates && \
    apt-get -q update && \
    apt-get install -q -y -t buster-backports --no-install-recommends \
        binutils \
        ccache \
        file \
        flex \
        git \
        google-perftools \
        jq \
        libfl-dev \
        libgoogle-perftools-dev \
        libkrb5-dev \
        libmaxminddb-dev \
        libpcap0.8-dev \
        libssl-dev \
        locales-all \
        make \
        ninja-build \
        patch \
        swig \
        zlib1g-dev && \
  apt-get install -q -y -t testing --no-install-recommends \
    bison \
    build-essential \
    cmake \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel && \
  pip3 install --no-cache-dir zkg btest pre-commit

# Build Zeek and Spicy
RUN cd "${SRC_BASE_DIR}" && \
    curl -sSL "https://old.zeek.org/downloads/zeek-${ZEEK_VERSION}.tar.gz" | tar xzf - -C "${SRC_BASE_DIR}" && \
    cd "./zeek-${ZEEK_VERSION}" && \
    ./configure --prefix="${ZEEK_DIR}" --generator=Ninja --ccache --enable-perftools && \
    cd build && \
    ninja && \
    ninja install && \
    zkg autoconfig && \
  cd "${SRC_BASE_DIR}" && \
    git -c core.askpass=true clone --branch "${SPICY_BRANCH}" --recursive "https://github.com/zeek/spicy" spicy && \
    cd ./spicy && \
    ./configure --generator=Ninja --prefix="${SPICY_DIR}" --with-zeek="${ZEEK_DIR}" --enable-ccache && \
    ninja -C build install && \
    bash -c "find ${ZEEK_DIR}/lib -type d -name CMakeFiles -exec rm -rf '{}' \; 2>/dev/null || true" && \
    bash -c "file ${ZEEK_DIR}/{lib,bin}/* ${ZEEK_DIR}/lib/zeek/plugins/packages/*/lib/* ${ZEEK_DIR}/lib/zeek/plugins/*/lib/* ${SPICY_DIR}/{lib,bin}/* ${SPICY_DIR}/lib/spicy/Zeek_Spicy/lib/* | grep 'ELF 64-bit' | sed 's/:.*//' | xargs -l -r strip -v --strip-unneeded"

# runtime stage

FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "zeek"
ENV PGROUP "zeek"
ENV PUSER_PRIV_DROP true

ENV ZEEK_DIR "/opt/zeek"
ENV SPICY_DIR "/opt/spicy"

# artifacts from build stage
COPY --from=build ${ZEEK_DIR} ${ZEEK_DIR}
COPY --from=build ${SPICY_DIR} ${SPICY_DIR}

# install runtime dependencies
RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian testing main" >> /etc/apt/sources.list && \
    echo "Package: bison,build-essential,cmake,python3,python3-dev,python3-pip,python3-setuptools,python3-wheel\\nPin: release a=testing\\nPin-Priority: 800\\n\\nPackage: *\\nPin: release a=stable\\nPin-Priority: 700\\n\\nPackage: *\\nPin: release a=buster-backports\\nPin-Priority: 650\\n\\n\\nPackage: *\\nPin: release a=testing\\nPin-Priority: 600\\n" > /etc/apt/preferences.d/pin && \
    echo 'APT::Default-Release "buster";' >> /etc/apt/apt.conf && \
      apt-get -q update && \
      apt-get install -q -y --no-install-recommends gnupg2 curl ca-certificates && \
    apt-get -q update && \
    apt-get install -q -y -t buster-backports --no-install-recommends \
      binutils \
      file \
      git \
      libatomic1 \
      libgoogle-perftools4 \
      libkrb5-3 \
      libmaxminddb0 \
      libpcap0.8 \
      libpcap0.8-dev \
      libssl1.0 \
      libtcmalloc-minimal4 \
      libunwind8 \
      libzmq5 \
      procps \
      psmisc \
      python \
      supervisor \
      vim-tiny && \
    apt-get install -q -y -t testing --no-install-recommends \
      bison \
      build-essential \
      cmake \
      python3 \
      python3-pip \
      python3-setuptools \
      python3-wheel && \
    pip3 install --no-cache-dir pyzmq && \
    bash -c "( find /opt/zeek/ -type l ! -exec test -r {} \; -print | xargs -r -l rm -vf ) || true" && \
    apt-get -q -y --purge remove libssl-dev && \
      apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# configure unprivileged user and runtime parameters

ARG ZEEK_LOGS_DIR=/zeek-logs
ENV ZEEK_LOGS_DIR $ZEEK_LOGS_DIR

ADD https://raw.githubusercontent.com/mmguero-personal/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
    useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER} && \
    mkdir -p "${ZEEK_LOGS_DIR}" && \
    chown ${PUSER}:${PGROUP} "${ZEEK_LOGS_DIR}" && \
    # make a setcap copy of zeek (zeekcap) for listening on an interface
    cp "${ZEEK_DIR}"/bin/zeek "${ZEEK_DIR}"/bin/zeekcap && \
    chown root:${PGROUP} "${ZEEK_DIR}"/bin/zeekcap && \
    setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_IPC_LOCK+eip' "${ZEEK_DIR}"/bin/zeekcap

ENV PATH "${ZEEK_DIR}/bin:${SPICY_DIR}/bin:${PATH}"

WORKDIR "${ZEEK_LOGS_DIR}"

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]
