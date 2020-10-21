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

ENV BISON_VERSION "3.7.2"
ENV CCACHE_DIR "/var/spool/ccache"
ENV CCACHE_COMPRESS 1
ENV CMAKE_DIR "/opt/cmake"
ENV CMAKE_VERSION "3.18.4"
ENV SPICY_DIR "/opt/spicy"
ENV SPICY_BRANCH "master"
ENV SRC_BASE_DIR "/usr/local/src"
ENV ZEEK_DIR "/opt/zeek"
ENV ZEEK_VERSION "3.0.11"

# using clang now instead of gcc because Spicy depends on it
ENV LLVM_VERSION "10"
ENV CC "clang-${LLVM_VERSION}"
ENV CXX "clang++-${LLVM_VERSION}"
ENV ASM "clang-${LLVM_VERSION}"

ENV PATH "${ZEEK_DIR}/bin:${CMAKE_DIR}/bin:${PATH}"

# configure system for build
RUN sed -i "s/buster main/buster main contrib non-free/g" /etc/apt/sources.list && \
      echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
      apt-get -q update && \
      apt-get install -q -y --no-install-recommends gnupg2 curl ca-certificates && \
      bash -c "curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -" && \
      echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-${LLVM_VERSION} main" >> /etc/apt/sources.list && \
      echo "deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-${LLVM_VERSION} main" >> /etc/apt/sources.list && \
    apt-get -q update && \
    apt-get install -q -y -t buster-backports --no-install-recommends \
        binutils \
        ccache \
        clang-${LLVM_VERSION} \
        file \
        flex \
        git \
        google-perftools \
        jq \
        libclang-${LLVM_VERSION}-dev \
        libfl-dev \
        libgoogle-perftools-dev \
        libkrb5-dev \
        libmaxminddb-dev \
        libpcap0.8-dev \
        libssl-dev \
        llvm-${LLVM_VERSION}-dev \
        locales-all \
        make \
        ninja-build \
        patch \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        swig \
        zlib1g-dev && \
  pip3 install --no-cache-dir zkg btest pre-commit && \
  # recent CMake
  mkdir -p "${CMAKE_DIR}" && \
    curl -sSL "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.tar.gz" | tar xzf - -C "${CMAKE_DIR}" --strip-components 1 && \
  # recent Bison
  cd /tmp && \
    curl -sSL "https://ftp.gnu.org/gnu/bison/bison-${BISON_VERSION}.tar.gz" | tar xzf - -C /tmp && \
    cd "./bison-${BISON_VERSION}" && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    cd /tmp && \
    rm -rf /tmp/bison*

# Build Zeek and Spicy
RUN cd "${SRC_BASE_DIR}" && \
    curl -sSL "https://old.zeek.org/downloads/zeek-${ZEEK_VERSION}.tar.gz" | tar xzf - -C "${SRC_BASE_DIR}" && \
    cd "./zeek-${ZEEK_VERSION}" && \
    ./configure --prefix="${ZEEK_DIR}" --generator=Ninja --ccache --enable-perftools && \
    cd build && \
    ninja && \
    ninja install && \
  cd "${SRC_BASE_DIR}" && \
    git -c core.askpass=true clone --branch "${SPICY_BRANCH}" --recursive "https://github.com/zeek/spicy" spicy && \
    cd ./spicy && \
    ./configure --generator=Ninja --prefix="${SPICY_DIR}" --with-zeek="${ZEEK_DIR}" --enable-ccache && \
    ninja -C build install && \
  bash -c "file ${ZEEK_DIR}/{lib,bin}/* ${ZEEK_DIR}/lib/zeek/plugins/packages/*/lib/* ${ZEEK_DIR}/lib/zeek/plugins/*/lib/* ${SPICY_DIR}/{lib,bin}/* ${SPICY_DIR}/lib/spicy/Zeek_Spicy/lib/* | grep 'ELF 64-bit' | sed 's/:.*//' | xargs -l -r strip -v --strip-unneeded"

# runtime stage

FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive

ENV LLVM_VERSION "10"
ENV ZEEK_DIR "/opt/zeek"
ENV SPICY_DIR "/opt/spicy"

# artifacts from build stage
COPY --from=build ${ZEEK_DIR} ${ZEEK_DIR}
COPY --from=build ${SPICY_DIR} ${SPICY_DIR}

# install runtime dependencies
RUN sed -i "s/buster main/buster main contrib non-free/g" /etc/apt/sources.list && \
      echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
      apt-get -q update && \
      apt-get install -q -y --no-install-recommends gnupg2 curl ca-certificates && \
      bash -c "curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -" && \
      echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-${LLVM_VERSION} main" >> /etc/apt/sources.list && \
      echo "deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-${LLVM_VERSION} main" >> /etc/apt/sources.list && \
    apt-get -q update && \
    apt-get install -q -y -t buster-backports --no-install-recommends \
      binutils \
      file \
      git \
      libatomic1 \
      libcap2-bin \
      libclang-${LLVM_VERSION}-dev \
      libclang-cpp${LLVM_VERSION} \
      libclang-cpp${LLVM_VERSION}-dev \
      libclang1-${LLVM_VERSION} \
      libgoogle-perftools4 \
      libkrb5-3 \
      libmaxminddb0 \
      libpcap0.8 \
      libpcap0.8-dev \
      libssl1.0 \
      libtcmalloc-minimal4 \
      libunwind8 \
      llvm-${LLVM_VERSION} \
      procps \
      psmisc \
      python \
      python3 \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      vim-tiny && \
    apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# configure unprivileged user and runtime parameters

ARG ZEEK_USER=zeek
ENV ZEEK_USER $ZEEK_USER

ARG ZEEK_LOGS_DIR=/zeek-logs
ENV ZEEK_LOGS_DIR $ZEEK_LOGS_DIR

RUN mkdir -p "${ZEEK_LOGS_DIR}" && \
    chown 1000:1000 "${ZEEK_LOGS_DIR}" && \
    groupadd --gid 1000 ${ZEEK_USER} && \
    useradd -M --uid 1000 --gid 1000 --home /nonexistant ${ZEEK_USER} && \
    # make a setcap'ed copy of zeek name "zeekcap" for listening on an interface
    cp "${ZEEK_DIR}"/bin/zeek "${ZEEK_DIR}"/bin/zeekcap && \
    chown root:$ZEEK_USER "${ZEEK_DIR}"/bin/zeekcap && \
    setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_IPC_LOCK+eip' "${ZEEK_DIR}"/bin/zeekcap

ENV PATH "${ZEEK_DIR}/bin:${SPICY_DIR}/bin:${PATH}"

USER $ZEEK_USER

WORKDIR "${ZEEK_LOGS_DIR}"
