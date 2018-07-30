FROM opengl-nvidia:latest

RUN sed -i "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list
RUN awk '$1 ~ "^deb" { $3 = $3 "-backports"; print; exit }' /etc/apt/sources.list >> /etc/apt/sources.list.d/debian_dists.list

RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y wget

RUN echo 'deb http://www.deb-multimedia.org jessie main non-free' > /etc/apt/sources.list.d/deb_multimedia.list
RUN wget -q http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb
RUN dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
RUN rm -f deb-multimedia-keyring_2016.8.1_all.deb

RUN  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list && \
  rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
  libexif12 \
  gimp \
  google-chrome-beta \
  mpv \
  ffmpeg \
  openjdk-7-jre \
  openssh-client \
  openssh-server \
  perl \
  sudo \
  vim-tiny \
  wget

RUN apt-get install -y -t jessie-backports \
  libreoffice

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
