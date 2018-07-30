FROM opengl-mesa:latest

RUN sed -i "s/testing main/testing main contrib non-free/" /etc/apt/sources.list

RUN apt-get update && apt-get update && apt-get dist-upgrade -y && \
  apt-get install -y \
    curl \
    openssh-client \
    openssh-server \
    perl \
    python \
    python-pip \
    python3 \
    python3-pip \
    rsync \
    screen \
    sudo \
    vim-tiny \
    wget && \
  apt-get -q -y autoremove && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser --uid 1000 --disabled-password --gecos '' --shell /bin/bash user && \
    usermod -a -G sudo user && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Define working directory.
WORKDIR /data

USER user
ENV HOME /home/user
CMD /bin/bash
