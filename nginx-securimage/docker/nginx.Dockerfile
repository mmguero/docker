FROM trafex/alpine-nginx-php7:latest

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/nginx-securimage'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='mmguero/nginx-securimage'
LABEL org.opencontainers.image.description='Dockerized NGINX with Securimage PHP Captcha'

ENV WEBROOT /var/www/html

RUN mkdir -p "$WEBROOT" && \
    cd "$WEBROOT" && \
    rm -f ./test.html && \
    mkdir ./securimage && \
    curl -ksSL "https://www.phpcaptcha.org/latest.tar.gz" | tar xzvf - -C ./securimage --strip-components 1 && \
    curl -ksSL -o /tmp/story.zip "https://html5up.net/story/download" && \
    unzip /tmp/story.zip -d "$WEBROOT" && \
    rm -f /tmp/story.zip "$WEBROOT"/index*html "$WEBROOT"/README.txt

ADD webcontent "$WEBROOT"

EXPOSE 8080

WORKDIR "$WEBROOT"

