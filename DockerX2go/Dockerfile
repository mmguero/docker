FROM ubuntu:latest
LABEL maintainer="tlacuache@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
  apt-get dist-upgrade -y && \
  apt-get install -y software-properties-common && \
  dpkg-divert --local --rename --add /sbin/initctl && \
    ln -sf /bin/true /sbin/initctl && \
    ( bash -c 'apt-get -y install fuse || :' ) && \
    rm -rf /var/lib/dpkg/info/fuse.postinst && \
  apt-get -q -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN add-apt-repository ppa:x2go/stable && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
      cryptsetup \
      cryptsetup-bin \
      curl \
      file \
      fonts-liberation \
      gcc-multilib \
      git \
      iproute2 \
      lxde \
      openssh-server \
      p7zip-full \
      pavucontrol \
      perl \
      pulseaudio \
      pwgen \
      python \
      python-pip \
      python3 \
      python3-pip \
      rsync \
      screen \
      sudo \
      tilix \
      tofrodos \
      unzip \
      vim-tiny \
      vlc \
      wget \
      x2goserver \
      x2golxdebindings \
      x2goserver-extensions \
      x2goserver-xsession \
      xdg-utils && \
    apt-get --purge remove -y xscreensaver && \
    apt-get -q -y autoremove && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -f /usr/share/lxde/wallpapers/*.jpg

RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
RUN sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN sed -i "s/#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config

# create home directories for dockerx user (password will be set on run)
RUN adduser --uid 1000 --disabled-password --gecos '' --shell /bin/bash dockerx && \
    usermod -a -G sudo dockerx && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /home/dockerx/.ssh && \
    chown -R dockerx:dockerx /home/dockerx/.ssh && \
    chmod 0700 /home/dockerx/.ssh

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh

EXPOSE 22

CMD ["/run.sh"]
