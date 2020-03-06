FROM linuxserver/calibre-web

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl xvfb libmagic1 imagemagick python2.7 python-pip python-setuptools python-wheel && \
    pip install filemagic ebooklib && \
    bash -c 'curl https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py | python2.7 -c "import sys; main=lambda:sys.stderr.write(\"Download failed\n\"); exec(sys.stdin.read()); main()"' && \
    ln -rs /opt/calibre/lib/libcalibre-launcher.so /usr/local/lib/libcalibre-launcher.so && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/*
