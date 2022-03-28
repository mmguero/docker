#!/bin/sh

if [ -n "$WIREPROXY_CONFIG_FROM_ENVS" ] && [ "$WIREPROXY_CONFIG_FROM_ENVS" == "true" ]; then
  /usr/bin/envsubst < /etc/wireproxy/config.env > /etc/wireproxy/config
fi

/usr/bin/wireproxy /etc/wireproxy/config
