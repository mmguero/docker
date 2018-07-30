FROM ubuntu:16.04
MAINTAINER tlacuache "Seth_Grover@McAfee.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && apt-get dist-upgrade -y && apt-get install -y software-properties-common python-software-properties wget && apt-get clean

RUN add-apt-repository ppa:x2go/stable

# Upstart and DBus have issues inside docker
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl

# Installing fuse package (libreoffice-java dependency) and it's going to try to create
# a fuse device without success, due the container permissions. || : help us to ignore it.
# Then we are going to delete the postinst fuse file and try to install it again!
RUN apt-get -y install fuse  || :
RUN rm -rf /var/lib/dpkg/info/fuse.postinst

RUN apt-get update -y && \
      apt-get install --no-install-recommends -y \
      sudo file rsync fuse tofrodos vim-tiny openssh-server lxde  x2goserver-xsession x2golxdebindings x2goserver-extensions x2goserver-pyhoca \
      pwgen pulseaudio pavucontrol libcurl3 libappindicator1 fonts-liberation xdg-utils \
      mpv libav-tools smplayer vlc youtube-dl gimp libexif12 libreoffice \
      unzip terminator autossh sshfs p7zip-full cryptsetup cryptsetup-bin \
      ant \
      autoconf \
      automake \
      autotools-dev \
      build-essential \
      cgdb \
      debhelper \
      devscripts \
      dh-make \
      doxygen \
      fakeroot \
      gcc-multilib \
      gdb \
      git \
      libgtk2.0-dev \
      libpango1.0-0 \
      libpcre3 \
      libpcre3-dev \
      libsort-naturally-perl \
      libxml-treepp-perl \
      libfile-copy-recursive-perl \
      lintian \
      openjdk-8-jdk \
      patch \
      patchutils \
      pbuilder \
      perl \
      python-setuptools \
      python-pip \
      rpm \
      tig && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java && \
      update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac && \
    pip install git-up && pip install colored && pip install git+git://github.com/badele/gitcheck.git && \
    (wget --no-check-certificate -O - http://caldo.ida.lab/debian/seth.grover@intel.com.gpg.key | apt-key add -) && \
      echo "deb http://caldo.ida.lab/debian unstable main" > /etc/apt/sources.list.d/nitroedb.list && \
      apt-get update && apt-get install --no-install-recommends -y fpc=3.0.4-37149 && \
    apt-get --purge remove -y chromium-browser xscreensaver && \
    apt-get clean && \
    rm -f /usr/share/lxde/wallpapers/*.jpg

RUN wget https://dl.google.com/linux/direct/google-chrome-beta_current_amd64.deb && \
      dpkg -i google-chrome*.deb && \
      apt-get install -f && apt-get clean && \
      ln -s /chrome.sh /usr/bin/chrome

RUN mkdir -p /var/run/sshd && sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
RUN sed -i "s/PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config
RUN sed -i "s/#PasswordAuthentication/PasswordAuthentication/g" /etc/ssh/sshd_config

# create home directories for dockerx user
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/dockerx && \
    echo "dockerx:x:${uid}:${gid}:Developer,,,:/home/dockerx:/bin/bash" >> /etc/passwd && \
    echo "dockerx:x:${uid}:" >> /etc/group && \
    echo "dockerx ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/dockerx && \
    chmod 0440 /etc/sudoers.d/dockerx && \
    chown ${uid}:${gid} -R /home/dockerx && \
    mkdir -p /home/dockerx/.ssh && \
    chown ${uid}:${gid} -R /home/dockerx/.ssh && \
    chmod 0700 /home/dockerx/.ssh

ADD set_root_pw.sh /set_root_pw.sh
ADD run.sh /run.sh
ADD chrome.sh /chrome.sh
RUN chmod +x /*.sh

EXPOSE 22

CMD ["/run.sh"]
