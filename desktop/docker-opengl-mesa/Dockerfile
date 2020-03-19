FROM debian:buster-slim

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y \
      binutils \
      curl \
      iproute2 \
      kmod \
      mesa-utils \
      wget \
      x-window-system

CMD /bin/bash
