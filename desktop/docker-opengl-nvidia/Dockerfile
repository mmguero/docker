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

ADD nvidia-driver.run /tmp/nvidia-driver.run
RUN sh /tmp/nvidia-driver.run -a -N --ui=none --no-kernel-module
RUN rm /tmp/nvidia-driver.run

CMD /bin/bash
