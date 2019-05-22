FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN sed -i 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get -qq update
RUN apt-get -qqy upgrade

# Install build dependencies (source: http://wiki.lineageos.org/athene_build.html)
# and other useful packages
RUN apt-get install -y android-tools-adb \
                       android-tools-fastboot \
                       bc \
                       bison \
                       build-essential \
                       curl \
                       flex \
                       g++-multilib \
                       gcc-multilib \
                       git \
                       gnupg \
                       gperf \
                       imagemagick \
                       lib32ncurses5-dev \
                       lib32readline6-dev \
                       lib32z1-dev \
                       libesd0-dev \
                       liblz4-tool \
                       libncurses5-dev \
                       libsdl1.2-dev \
                       libwxgtk3.0-dev \
                       libxml2 \
                       libxml2-utils \
                       lzop \
                       openjdk-8-jdk \
                       pngcrush \
                       schedtool \
                       squashfs-tools \
                       xsltproc \
                       zip \
                       zlib1g-dev \
                       ccache rsync tig sudo imagemagick \
                       bc bsdmainutils file screen \
                       bash-completion wget nano vim-tiny

RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

VOLUME /root/android

CMD /bin/bash

USER root
WORKDIR /root/android
