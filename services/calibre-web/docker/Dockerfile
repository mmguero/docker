FROM linuxserver/calibre-web

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      curl \
      imagemagick \
      libmagic1 \
      python-pip \
      python-setuptools \
      python-wheel \
      python2.7 \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      xvfb && \
    pip2 install filemagic ebooklib && \
    pip3 install Flask-SimpleLDAP python-ldap goodreads python-Levenshtein lxml Pillow rarfile && \
    bash -c 'curl https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python2.7 -c "import sys; main=lambda:sys.stderr.write(\"Download failed\n\"); exec(sys.stdin.read()); main()"' && \
    ln -rs /opt/calibre/lib/libcalibre-launcher.so /usr/local/lib/libcalibre-launcher.so && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/*
