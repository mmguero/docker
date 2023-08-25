FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "rooper"
ENV PGROUP "rooper"
ENV PUSER_PRIV_DROP true
ENV PUSER_RLIMIT_UNLOCK true

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

ARG BUFFALO_VER=0.7
ARG FACEXLIB_DET_VER=0.1.0
ARG FACEXLIB_PARSENET_VER=0.2.2
ARG GFPGAN_VER=1.4
ARG ROOP_BRANCH=main
ARG ROOP_REPO=mmguero

ENV BUFFALO_L_URL "https://github.com/deepinsight/insightface/releases/download/v${BUFFALO_VER}/buffalo_l.zip"
ENV FACEXLIB_DET_URL "https://github.com/xinntao/facexlib/releases/download/v0.1.0/detection_Resnet50_Final.pth"
ENV FACEXLIB_PARSENET_URL "https://github.com/xinntao/facexlib/releases/download/v0.2.2/parsing_parsenet.pth"
ENV GFPGAN_URL "https://github.com/TencentARC/GFPGAN/releases/download/v1.3.4/GFPGANv${GFPGAN_VER}.pth"
ENV INSWAPPER_128_URL "https://huggingface.co/facefusion/models/resolve/main/inswapper_128.onnx"
ENV ROOP_URL "https://codeload.github.com/${ROOP_REPO}/roop/tar.gz/${ROOP_BRANCH}"

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN apt-get -q update && \
    apt-get install -q -y --no-install-recommends \
        build-essential \
        curl \
        ffmpeg \
        procps \
        psmisc \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-tk \
        python3-wheel \
        sudo \
        tini \
        unzip \
        vim-tiny \
        zlib1g && \
    sed -i "s/set[[:space:]]*compatible/set nocompatible/g" /etc/vim/vimrc.tiny && \
    groupadd --gid ${DEFAULT_GID} ${PGROUP} && \
      useradd -m --uid ${DEFAULT_UID} --gid ${DEFAULT_GID} --home /home/${PUSER} ${PUSER} && \
      usermod -a -G tty ${PUSER} && \
      chsh -s /bin/bash ${PUSER} && \
      usermod -a -G sudo ${PUSER} && \
      echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /roop/models/gfpgan/weights /home/${PUSER}/.insightface/models/buffalo_l && \
    cd / && \
      curl -k -sSL "$ROOP_URL" | tar xzvf - -C ./roop --strip-components 1 && \
    curl -fsSL -o /roop/models/inswapper_128.onnx "${INSWAPPER_128_URL}" && \
        ln -s -r /roop/models/inswapper_128.onnx /roop/models/roopVideoFace_v10.onnx && \
    curl -fsSL -o "/roop/models/gfpgan/GFPGANv${GFPGAN_VER}.pth" "${GFPGAN_URL}" && \
        ln -s -r "/roop/models/gfpgan/GFPGANv${GFPGAN_VER}.pth" "/roop/models/GFPGANv${GFPGAN_VER}.pth" && \
    curl -fsSL -o /roop/models/gfpgan/weights/detection_Resnet50_Final.pth "${FACEXLIB_DET_URL}" && \
    curl -fsSL -o /roop/models/gfpgan/weights/parsing_parsenet.pth "${FACEXLIB_PARSENET_URL}" && \
    curl -fsSL -o /tmp/buffalo_l.zip "${BUFFALO_L_URL}" && \
        cd /home/${PUSER}/.insightface/models/buffalo_l && \
        unzip /tmp/buffalo_l.zip -d /home/${PUSER}/.insightface/models/buffalo_l && \
    python3 -m pip install --index-url https://download.pytorch.org/whl/cu118 torch torchvision torchaudio && \
        python3 -m pip install onnxruntime-gpu && \
        python3 -m pip install -r /roop/requirements.txt && \
    ln -s -r /usr/local/cuda-11.8/targets/x86_64-linux/lib/libnvrtc.so.11.2 /usr/local/cuda-11.8/targets/x86_64-linux/lib/libnvrtc.so.11 && \
        ln -s -r /usr/local/cuda-11.8/targets/x86_64-linux/lib/libnvrtc.so.11 /usr/local/cuda-11.8/targets/x86_64-linux/lib/libnvrtc.so && \
    chown -R ${PUSER}:${PGROUP} /home/${PUSER} /roop && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh /roop/run.py && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages --purge remove \
        build-essential \
        curl \
        python3-dev \
        unzip && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,video
ENV CUDA_DEVICE_ORDER FASTEST_FIRST
ENV CUDA_VISIBLE_DEVICES 0

WORKDIR /roop

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/docker-uid-gid-setup.sh"]
