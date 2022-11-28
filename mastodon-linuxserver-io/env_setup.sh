#!/usr/bin/env bash

# this is a bash script
if [ -z "$BASH_VERSION" ]; then
  echo "Wrong interpreter, please run \"$0\" with bash"
  exit 1
fi

if [ -t 0 ]; then
  INTERACTIVE_SHELL=yes
else
  INTERACTIVE_SHELL=no
fi

set -e
set -u
set -o pipefail
shopt -s nullglob

ENCODING="utf-8"

# force-navigate to base directory (where this script lives)
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "$SCRIPT_PATH" >/dev/null 2>&1

# stuff for running the image to generate secrets
MASTODON_IMAGE=${MASTODON_IMAGE:-ghcr.io/mmguero/mastodon:latest}
CONTAINER_ENGINE="${CONTAINER_ENGINE:-docker}"
if [[ "$CONTAINER_ENGINE" == "podman" ]]; then
  DEFAULT_UID=0
  DEFAULT_GID=0
else
  DEFAULT_UID=$(id -u)
  DEFAULT_GID=$(id -g)
fi

# do we really want to do this?
unset CONFIRMATION
[[ $INTERACTIVE_SHELL == "no" ]] || read -p "(Re)generate secrets [Y/n]? " CONFIRMATION
CONFIRMATION=${CONFIRMATION:-Y}
if [[ $CONFIRMATION =~ ^[Yy]$ ]]; then

  # generate secrets
  REDIS_HOST=redis
  REDIS_PORT=6379
  POSTGRES_HOST=postgres
  POSTGRES_USER=mastodon
  POSTGRES_DB_NAME=mastodon
  POSTGRES_DB_PORT=5432
  POSTGRES_PASSWORD="$(LC_ALL=C tr -dc 'A-Za-z0-9_' </dev/urandom | head -c 16 ; echo)"
  SECRET_KEY_BASE="$($CONTAINER_ENGINE run --rm -it -w /app/www --entrypoint rake $MASTODON_IMAGE secret)"
  OTP_SECRET="$($CONTAINER_ENGINE run --rm -it -w /app/www --entrypoint rake $MASTODON_IMAGE secret)"
  eval $($CONTAINER_ENGINE run --rm -it -w /app/www --entrypoint rake $MASTODON_IMAGE mastodon:webpush:generate_vapid_key)

  # update postresql env file with secrets
  cat <<EOF > env.postgres
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=${POSTGRES_DB_NAME}
POSTGRES_INITDB_ARGS="--encoding=UTF-8"
EOF

  # update mastodon env file with secrets
  [[ ! -f ./env.production ]] && [[ -f ./env.production.sample ]] && cp ./env.production.sample ./env.production
  sed -i "s/^\(DB_HOST=\).*/\1${POSTGRES_HOST}/" ./env.production
  sed -i "s/^\(DB_NAME=\).*/\1${POSTGRES_DB_NAME}/" ./env.production
  sed -i "s/^\(DB_PASS=\).*/\1${POSTGRES_PASSWORD}/" ./env.production
  sed -i "s/^\(DB_PORT=\).*/\1${POSTGRES_DB_PORT}/" ./env.production
  sed -i "s/^\(DB_USER=\).*/\1${POSTGRES_USER}/" ./env.production
  sed -i "s/^\(REDIS_HOST=\).*/\1${REDIS_HOST}/" ./env.production
  sed -i "s/^\(REDIS_PORT=\).*/\1${REDIS_PORT}/" ./env.production
  sed -i "s/^\(OTP_SECRET=\).*/\1${OTP_SECRET}/" ./env.production
  sed -i "s/^\(SECRET_KEY_BASE=\).*/\1${SECRET_KEY_BASE}/" ./env.production
  sed -i "s/^\(VAPID_PRIVATE_KEY=\).*/\1${VAPID_PRIVATE_KEY}/" ./env.production
  sed -i "s/^\(VAPID_PUBLIC_KEY=\).*/\1${VAPID_PUBLIC_KEY}/" ./env.production
fi
mkdir -p ./db ./config

popd >/dev/null 2>&1
