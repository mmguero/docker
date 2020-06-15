# docker run -d --rm \
#   -v /tmp/.X11-unix:/tmp/.X11-unix \
#   -e DISPLAY=unix\$DISPLAY \
#  --device /dev/video0 \
#  --device /dev/snd:/dev/snd \
#  --device /dev/dri \
#  -v /dev/shm:/dev/shm \
#  jess/zoom-us

FROM jess/zoom-us:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      pulseaudio-utils && \
  rm -rf /var/lib/apt/lists/*
