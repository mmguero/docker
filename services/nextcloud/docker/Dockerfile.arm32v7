FROM arm32v7/nextcloud:latest

RUN apt-get update && \
    apt-get -y -q --no-install-recommends install smbclient && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

