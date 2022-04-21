FROM debian:bullseye-slim

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/gimp'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/gimp'
LABEL org.opencontainers.image.description='Dockerized GIMP (X11)'

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# configure unprivileged user and runtime parameters
ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "gimp"
ENV PGROUP "gimp"
ENV PUSER_PRIV_DROP true

ENV PHOTOGIMP_URL "https://codeload.github.com/Diolinux/PhotoGIMP/tar.gz/master"

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN sed -i "s/bullseye main/bullseye main contrib non-free/g" /etc/apt/sources.list && \
    apt-get -q update && \
    apt-get install --no-install-recommends -y -q \
      curl \
      gimp \
      gimp-gmic \
      gimp-plugin-registry \
      gimp-texturize \
      gmic \
      gnome-icon-theme \
      gtk2-engines-pixbuf \
      libgl1-mesa-dri \
      libgl1-mesa-glx \
      libgmic1 && \
    cd /tmp && \
      mkdir ./photogimp && \
      curl -k -sSL "$PHOTOGIMP_URL" | tar xzvf - -C ./photogimp --strip-components 1 && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
      groupadd --gid ${DEFAULT_GID} ${PUSER} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} ${PUSER} && \
      mkdir -p /home/${PUSER}/.config/GIMP \
               /home/${PUSER}/.fonts \
               /home/${PUSER}/Documents && \
      mv /tmp/photogimp/.var/app/org.gimp.GIMP/config/GIMP/2.10 /home/${PUSER}/.config/GIMP/ && \
      chown -R ${DEFAULT_UID}:${DEFAULT_GID} /home/${PUSER} && \
    apt-get -q -y --purge remove curl && \
      apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh", "/usr/bin/gimp"]

VOLUME ["/home/${PUSER}/.config/GIMP"]
