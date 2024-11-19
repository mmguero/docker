FROM alpine:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/yt-dlp'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='oci.guero.org/yt-dlp'
LABEL org.opencontainers.image.description='Dockerized yt-dlp'

ARG DEFAULT_UID=1000
ARG DEFAULT_GID=1000
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "ytdlp"
ENV PGROUP "ytdlp"
ENV PUSER_PRIV_DROP true

ENV PYTHONUNBUFFERED 1

COPY --from=mwader/static-ffmpeg:latest /ffmpeg /ffprobe /usr/bin/
ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh

RUN apk add --update --no-cache bash curl shadow py3-pip && \
    apk add --no-cache --virtual .build-deps \
        build-base \
        gcc \
        make \
        musl-dev \
        python3-dev \
        py3-setuptools \
        py3-wheel && \
    python3 -m pip install --break-system-packages --no-cache yt-dlp && \
    apk del .build-deps && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh && \
    addgroup -g ${DEFAULT_GID} ${PGROUP} && \
      adduser -D -H -u ${DEFAULT_UID} -h /nonexistant -s /sbin/nologin -G ${PGROUP} -g ${PUSER} ${PUSER} && \
      addgroup ${PUSER} tty && \
      addgroup ${PUSER} shadow

ENTRYPOINT ["/usr/local/bin/docker-uid-gid-setup.sh", "/usr/bin/yt-dlp"]

CMD []
