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

FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

# for download and install
ARG ZEEK_LTS=1
ARG ZEEK_VERSION=4.0.1-0
ARG SPICY_VERSION=1.0.0

ENV ZEEK_LTS $ZEEK_LTS
ENV ZEEK_VERSION $ZEEK_VERSION
ENV SPICY_VERSION $SPICY_VERSION

# for build
ENV LLVM_VERSION "12"
ENV CC "clang-${LLVM_VERSION}"
ENV CXX "clang++-${LLVM_VERSION}"
ENV ASM "clang-${LLVM_VERSION}"
ENV CCACHE_DIR "/var/spool/ccache"
ENV CCACHE_COMPRESS 1

# put Zeek and Spicy in PATH
ENV ZEEK_DIR "/opt/zeek"
ENV SPICY_DIR "/opt/spicy"
ENV PATH "${ZEEK_DIR}/bin:${SPICY_DIR}/bin:${ZEEK_DIR}/lib/zeek/plugins/packages/spicy-plugin/bin:${PATH}"

RUN echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && \
    apt-get -q update && \
    apt-get install -q -y --no-install-recommends \
      ca-certificates \
      curl \
      file \
      git \
      gnupg2 \
      jq \
      less \
      libcap2-bin \
      moreutils \
      procps \
      psmisc \
      vim-tiny && \
    ( curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - ) && \
    echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-${LLVM_VERSION} main" >> /etc/apt/sources.list && \
    echo "deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-${LLVM_VERSION} main" >> /etc/apt/sources.list && \
    apt-get -q update && \
    apt-get install -q -y -t buster-backports --no-install-recommends \
      bison \
      ccache \
      clang-${LLVM_VERSION} \
      cmake \
      flex \
      libclang-${LLVM_VERSION}-dev \
      libfl-dev \
      libmaxminddb-dev \
      libmaxminddb0 \
      libpcap-dev \
      libpcap0.8 \
      libssl-dev \
      llvm-${LLVM_VERSION}-dev \
      locales-all \
      make \
      ninja-build \
      python3 \
      python3-git \
      python3-pip \
      python3-semantic-version \
      python3-setuptools \
      python3-wheel \
      zlib1g-dev && \
    mkdir -p /tmp/zeek-packages && \
      cd /tmp/zeek-packages && \
      if [ -n "${ZEEK_LTS}" ]; then ZEEK_LTS="-lts"; fi && export ZEEK_LTS && \
      curl -sSL --remote-name-all \
        "https://download.zeek.org/binary-packages/Debian_10/amd64/libbroker${ZEEK_LTS}-dev_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/Debian_10/amd64/zeek${ZEEK_LTS}-core-dev_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/Debian_10/amd64/zeek${ZEEK_LTS}-core_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/Debian_10/amd64/zeek${ZEEK_LTS}-libcaf-dev_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/Debian_10/amd64/zeek${ZEEK_LTS}_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/Debian_10/amd64/zeek${ZEEK_LTS}-btest_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/Debian_10/amd64/zeek${ZEEK_LTS}-zkg_${ZEEK_VERSION}_amd64.deb" \
        "https://download.zeek.org/binary-packages/Debian_10/amd64/zeekctl${ZEEK_LTS}_${ZEEK_VERSION}_amd64.deb" && \
      dpkg -i ./*.deb && \
    mkdir -p /tmp/spicy-packages && \
      cd /tmp/spicy-packages && \
    curl -sSL --remote-name-all \
      "https://github.com/zeek/spicy/releases/download/v${SPICY_VERSION}/spicy_linux_debian10.deb" && \
      dpkg -i ./*.deb && \
    cd /tmp && \
    mkdir -p "${CCACHE_DIR}" && \
    zkg autoconfig --force && \
    echo "@load packages" >> "${ZEEK_DIR}"/share/zeek/site/local.zeek && \
    zkg install --force --skiptests zeek/spicy-plugin && \
    ( find "${ZEEK_DIR}"/lib -type d -name CMakeFiles -exec rm -rf "{}" \; 2>/dev/null || true ) && \
    ( find "${ZEEK_DIR}"/var/lib/zkg -type d -name build -exec rm -rf "{}" \; 2>/dev/null || true ) && \
    ( find "${ZEEK_DIR}"/var/lib/zkg/clones -type d -name .git -execdir bash -c "pwd; du -sh; git pull --depth=1 --ff-only; git reflog expire --expire=all --all; git tag -l | xargs -r git tag -d; git gc --prune=all; du -sh" \; ) && \
    rm -rf "${ZEEK_DIR}"/var/lib/zkg/scratch && \
    ( find "${ZEEK_DIR}/" "${SPICY_DIR}/" -type f -exec file "{}" \; | grep -Pi "ELF 64-bit.*not stripped" | sed 's/:.*//' | xargs -l -r strip --strip-unneeded ) && \
    mkdir -p "${ZEEK_DIR}"/var/lib/zkg/clones/package/spicy-plugin/build/plugin/bin/ && \
      ln -s -r "${ZEEK_DIR}"/lib/zeek/plugins/packages/spicy-plugin/bin/spicyz \
               "${ZEEK_DIR}"/var/lib/zkg/clones/package/spicy-plugin/build/plugin/bin/spicyz && \
    mkdir -p "${ZEEK_DIR}"/var/lib/zkg/clones/package/spicy-plugin/plugin/lib/ && \
      ln -s -r "${ZEEK_DIR}"/lib/zeek/plugins/packages/spicy-plugin/lib/bif \
               "${ZEEK_DIR}"/var/lib/zkg/clones/package/spicy-plugin/plugin/lib/bif && \
    cd /usr/lib/locale && \
      ( ls | grep -Piv "^(en|en_US|en_US\.utf-?8|C\.utf-?8)$" | xargs -l -r rm -rf ) && \
    cd /tmp && \
    apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*/*

# configure unprivileged user and runtime parameters
ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "zeekcap"
ENV PGROUP "zeekcap"
ENV PUSER_PRIV_DROP true

ARG ZEEK_LOGS_DIR=/zeek-logs
ENV ZEEK_LOGS_DIR $ZEEK_LOGS_DIR

ADD https://raw.githubusercontent.com/mmguero-personal/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD login.zeek "${ZEEK_DIR}"/share/zeek/site/

RUN chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    groupadd --gid ${DEFAULT_GID} ${PUSER} && \
    useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER} && \
    mkdir -p "${ZEEK_LOGS_DIR}" && \
    chown ${PUSER}:${PGROUP} "${ZEEK_LOGS_DIR}" && \
    # make a setcap copy of zeek (zeekcap) for listening on an interface
    cp "${ZEEK_DIR}"/bin/zeek "${ZEEK_DIR}"/bin/zeekcap && \
    chown root:${PGROUP} "${ZEEK_DIR}"/bin/zeekcap && \
    setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip CAP_IPC_LOCK+eip' "${ZEEK_DIR}"/bin/zeekcap

WORKDIR "${ZEEK_LOGS_DIR}"

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh"]
