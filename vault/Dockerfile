  # base image
FROM alpine:3.11

LABEL maintainer="mero.mero.guero@gmail.com"
LABEL org.opencontainers.image.authors='mero.mero.guero@gmail.com'
LABEL org.opencontainers.image.url='https://github.com/mmguero/docker/tree/master/vault'
LABEL org.opencontainers.image.source='https://github.com/mmguero/docker'
LABEL org.opencontainers.image.title='mmguero/vault'
LABEL org.opencontainers.image.description='Dockerized Hashicorp Vault'

# set vault version
ENV VAULT_VERSION 1.4.1

# create a new directory
RUN mkdir /vault

# download dependencies
RUN apk --no-cache add \
      bash \
      ca-certificates \
      curl \
      jq \
      openssl \
      wget

# download and set up vault
RUN wget --quiet --output-document=/tmp/vault.zip https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /vault && \
    rm -f /tmp/vault.zip && \
    chmod +x /vault

# update PATH
ENV PATH="PATH=$PATH:$PWD/vault"

# add the config file
COPY ./config/vault-config.json /vault/config/vault-config.json

# expose port 8200
EXPOSE 8200

# run vault
ENTRYPOINT ["vault"]
