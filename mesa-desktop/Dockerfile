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

RUN export uid=1000 gid=1000 && \
    mkdir -p /home/user && \
    echo "user:x:${uid}:${gid}:user,,,:/home/user:/bin/bash" >> /etc/passwd && \
    echo "user:x:${uid}:" >> /etc/group && \
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user && \
    chown ${uid}:${gid} -R /home/user

# Define working directory.
WORKDIR /data

USER user
ENV HOME /home/user
CMD /bin/bash
