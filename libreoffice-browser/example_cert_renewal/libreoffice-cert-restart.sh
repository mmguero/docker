#!/usr/bin/env bash

set -e

NGINX_CERTS_DIR="$(realpath ~/services/libreoffice/nginx/certs)"

# force-navigate to script directory (containing certificates)
RUN_PATH="$(pwd)"
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "$SCRIPT_PATH" >/dev/null 2>&1

if [[ -r ./service.key ]] && [[ -r ./service.crt ]] && [[ -d "$NGINX_CERTS_DIR" ]]; then
  pushd "$NGINX_CERTS_DIR"/../../ >/dev/null 2>&1
  /bin/cp -vf "$SCRIPT_PATH"/service.key "$NGINX_CERTS_DIR"/key.pem
  /bin/cp -vf "$SCRIPT_PATH"/service.crt "$NGINX_CERTS_DIR"/cert.pem
  chmod 644 "$NGINX_CERTS_DIR"/cert.pem
  chmod 600 "$NGINX_CERTS_DIR"/key.pem
  docker-compose ps nginx-ldap >/dev/null 2>&1 && docker-compose exec nginx-ldap nginx -s reload
  popd >/dev/null 2>&1
fi

popd >/dev/null 2>&1