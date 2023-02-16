FROM linuxserver/calibre-web:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/calibre-web'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/calibre-web'
LABEL org.opencontainers.image.description='Dockerized Calibre-Web E-Book Server'

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      curl \
      imagemagick \
      libegl1 \
      libjpeg-turbo8 \
      libjpeg8 \
      libmagic1 \
      libopengl0 \
      python3 \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      xdg-utils \
      xvfb \
      xz-utils \
      zlib1g && \
    pip3 install filemagic ebooklib Flask-SimpleLDAP python-ldap goodreads python-Levenshtein lxml Pillow rarfile && \
    bash -c 'curl https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python3 -c "import sys; main=lambda:sys.stderr.write(\"Download failed\n\"); exec(sys.stdin.read()); main()"' && \
    ln -rs /opt/calibre/lib/libcalibre-launcher.so /usr/local/lib/libcalibre-launcher.so && \
    apt-get -y --allow-downgrades --allow-remove-essential --allow-change-held-packages autoremove && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/*
