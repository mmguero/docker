FROM debian:12-slim AS npmget

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt-get -q update && \
    apt-get -y -q --no-install-recommends upgrade && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages install --no-install-recommends npm node-encoding git ca-certificates curl wget && \
    npm install -g \
      filepond \
      filepond-plugin-file-validate-size \
      filepond-plugin-file-validate-type \
      filepond-plugin-file-metadata \
      filepond-plugin-file-rename \
      @jcubic/tagger

FROM debian:12-slim AS runtime

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/filepond'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='ghcr.io/mmguero/filepond-nginx'
LABEL org.opencontainers.image.description='FilePond with NGINX and PHP'

ARG DEFAULT_UID=33
ARG DEFAULT_GID=33
ENV DEFAULT_UID $DEFAULT_UID
ENV DEFAULT_GID $DEFAULT_GID
ENV PUSER "www-data"
ENV PGROUP "www-data"
# not dropping privileges globally in this container, but this can be handled by supervisord
# instead on an as-needed basis, and nginx itself will drop privileges to www-data as well.
ENV PUSER_PRIV_DROP false

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

ARG PHP_VERSION=8.2
ENV PHP_VERSION $PHP_VERSION

ARG FILEPOND_SERVER_BRANCH=master
ENV FILEPOND_SERVER_BRANCH $FILEPOND_SERVER_BRANCH

ENV SUPERCRONIC_VERSION "0.2.26"
ENV SUPERCRONIC_URL "https://github.com/aptible/supercronic/releases/download/v$SUPERCRONIC_VERSION/supercronic-linux-amd64"
ENV SUPERCRONIC "supercronic-linux-amd64"
ENV SUPERCRONIC_SHA1SUM "7a79496cf8ad899b99a719355d4db27422396735"
ENV SUPERCRONIC_CRONTAB "/etc/crontab"

ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/docker-uid-gid-setup.sh /usr/local/bin/docker-uid-gid-setup.sh
ADD https://raw.githubusercontent.com/mmguero/docker/master/shared/service_check_passthrough.sh /usr/local/bin/service_check_passthrough.sh

COPY --from=npmget /usr/local/lib/node_modules/filepond /var/www/upload/filepond
COPY --from=npmget /usr/local/lib/node_modules/filepond-plugin-file-validate-size /var/www/upload/filepond-plugin-file-validate-size
COPY --from=npmget /usr/local/lib/node_modules/filepond-plugin-file-validate-type /var/www/upload/filepond-plugin-file-validate-type
COPY --from=npmget /usr/local/lib/node_modules/filepond-plugin-file-metadata /var/www/upload/filepond-plugin-file-metadata
COPY --from=npmget /usr/local/lib/node_modules/filepond-plugin-file-rename /var/www/upload/filepond-plugin-file-rename
COPY --from=npmget /usr/local/lib/node_modules/@jcubic /var/www/upload/@jcubic

RUN apt-get -q update && \
    apt-get -y -q --no-install-recommends upgrade && \
    apt-get -y -q --allow-downgrades --allow-remove-essential --allow-change-held-packages install --no-install-recommends \
      ca-certificates \
      curl \
      file \
      less \
      nginx-light \
      php$PHP_VERSION \
      php$PHP_VERSION-apcu \
      php$PHP_VERSION-fpm \
      rsync \
      supervisor \
      tini \
      vim-tiny && \
    curl -fsSLO "$SUPERCRONIC_URL" && \
      echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - && \
      chmod +x "$SUPERCRONIC" && \
      mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
      ln -sr "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic && \
    touch ${SUPERCRONIC_CRONTAB} && \
    mkdir -p /run/php \
             /var/www/upload/server/php/files/tmp \
             /var/www/upload/server/php/files/variants \
             /tmp/filepond-server && \
    cd /tmp && \
      curl -sSL "https://github.com/pqina/filepond-server-php/archive/${FILEPOND_SERVER_BRANCH}.tar.gz" | tar xzvf - -C ./filepond-server --strip-components 1 && \
      rsync -a --include="*/" --include="*.php" --exclude="*" ./filepond-server/ /var/www/upload/server/php/ && \
    ln -sr /var/www/upload /var/www/upload/upload && \
    chmod 775 /var/www/upload/server/php/files \
              /var/www/upload/server/php/files/tmp \
              /var/www/upload/server/php/files/variants && \
    chmod 755 /usr/local/bin/docker-uid-gid-setup.sh \
              /usr/local/bin/service_check_passthrough.sh \
              /var /var/www /var/www/upload \
              /var/www/upload/server  \
              /var/www/upload/server/php && \
    apt-get clean -y -q && \
      rm -rf /var/lib/apt/lists/* /var/cache/* /tmp/* /var/tmp/*

ADD nginx/sites-available/default /etc/nginx/sites-available/default
ADD php/php.ini /etc/php/$PHP_VERSION/fpm/php.ini
ADD php/*.php /var/www/upload/server/php/
ADD site/index.html /var/www/upload/index.html
ADD supervisord.conf /supervisord.conf

VOLUME [ "/var/www/upload/server/php/files" ]
EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", \
            "--", \
            "/usr/local/bin/docker-uid-gid-setup.sh", \
            "/usr/local/bin/service_check_passthrough.sh", \
            "-s", "filepond"]

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf", "-u", "root", "-n"]
