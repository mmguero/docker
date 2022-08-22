#!/usr/bin/env bash

IMAGE="${GLAUTH_IMAGE:-ghcr.io/mmguero/glauth}"
ENGINE="${CONTAINER_ENGINE:-docker}"

set -e
set -o pipefail
set -u

ENCODING="utf-8"

[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME" && type $ENGINE) > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $ENGINE, $REALPATH and $DIRNAME"
  exit 1
fi
export SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"

pushd "$SCRIPT_PATH"/ >/dev/null 2>&1

$ENGINE build -f standalone.Dockerfile -t "${IMAGE}":standalone .
$ENGINE build -f plugins.Dockerfile -t "${IMAGE}":plugins .

if command -v curl >/dev/null 2>&1; then
  GLAUTH_RELEASE="$($ENGINE run --rm --entrypoint=/usr/bin/cat "${IMAGE}":standalone /app/version.txt | head -n 1)"
  if [[ -n "$GLAUTH_RELEASE" ]]; then
    [[ ! -f ./config-standalone.cfg ]] && \
      curl -sSL -o ./config-standalone.cfg https://raw.githubusercontent.com/glauth/glauth/${GLAUTH_RELEASE}/v2/scripts/docker/default-config-standalone.cfg && \
      chmod 600 ./config-standalone.cfg
    [[ ! -f ./config-plugins.cfg ]] && \
      curl -sSL -o ./config-plugins.cfg https://raw.githubusercontent.com/glauth/glauth/${GLAUTH_RELEASE}/v2/scripts/docker/default-config-plugins.cfg && \
      chmod 600 ./config-plugins.cfg
    [[ ! -f ./gl.db ]] && \
      curl -sSL -o ./gl.db https://raw.githubusercontent.com/glauth/glauth/${GLAUTH_RELEASE}/v2/scripts/docker/gl.db && \
      chmod 600 ./gl.db
  fi
fi

popd >/dev/null 2>&1