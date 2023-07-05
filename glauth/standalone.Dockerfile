##################################
# Get release artifacts from GitHub
##################################

FROM alpine:latest as prep

ARG GLAUTH_RELEASE=v2.2.0
ENV $GLAUTH_RELEASE $GLAUTH_RELEASE

RUN mkdir -p /app/v2 && \
    apk add --no-cache curl busybox-static dumb-init unzip && \
    uname -a && \
    if [ $(uname -m) == x86_64 ]; then curl -sSL -o /tmp/glauth.zip https://github.com/glauth/glauth/releases/download/${GLAUTH_RELEASE}/linuxamd64.zip; fi && \
    if [ $(uname -m) == aarch64 ]; then curl -sSL -o /tmp/glauth.zip https://github.com/glauth/glauth/releases/download/${GLAUTH_RELEASE}/linuxarm64.zip; fi && \
    if [ $(uname -m) == armv7l ]; then curl -sSL -o /tmp/glauth.zip https://github.com/glauth/glauth/releases/download/${GLAUTH_RELEASE}/linuxarm.zip; fi && \
    unzip /tmp/glauth.zip -d /app/v2

#################
# Run
#################

FROM gcr.io/distroless/base-debian10 as run

ARG GLAUTH_RELEASE=v2.2.0
ENV $GLAUTH_RELEASE $GLAUTH_RELEASE

ADD https://raw.githubusercontent.com/glauth/glauth/${GLAUTH_RELEASE}/v2/scripts/docker/start-standalone.sh /app/docker/
ADD https://raw.githubusercontent.com/glauth/glauth/${GLAUTH_RELEASE}/v2/scripts/docker/default-config-standalone.cfg /app/docker/

COPY --from=prep /app/v2/glauth /app/glauth
COPY --from=prep /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=prep /bin/busybox.static /bin/sh
COPY --from=prep /bin/busybox.static /bin/ln
COPY --from=prep /bin/busybox.static /bin/rm
RUN /app/glauth --version && \
    echo "${GLAUTH_RELEASE}" > /app/version.txt && \
    ln /bin/sh /usr/bin/cat && \
    ln /bin/sh /usr/bin/cp && \
    ln /bin/sh /usr/bin/ls && \
    ln /bin/sh /usr/bin/mkdir && \
    rm /bin/ln /bin/rm

EXPOSE 389 636 5555

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/bin/sh", "/app/docker/start-standalone.sh"]
