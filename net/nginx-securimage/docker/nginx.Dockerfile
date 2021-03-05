FROM trafex/alpine-nginx-php7:latest

ENV WEBROOT /var/www/html

ADD webcontent "$WEBROOT"

RUN mkdir -p "$WEBROOT" && \
    cd "$WEBROOT" && \
    rm -f ./test.html && \
    mkdir ./securimage && \
    curl -sSL "https://www.phpcaptcha.org/latest.tar.gz" | tar xzvf - -C ./securimage --strip-components 1

EXPOSE 8080
