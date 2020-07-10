#!/bin/bash

if [ -z "$BASH_VERSION" ]; then
  echo "Wrong interpreter, please run \"$0\" with bash"
  exit 1
fi

set -e

if docker version >/dev/null 2>&1; then
  DOCKER_BIN=docker
elif grep -q Microsoft /proc/version && docker.exe version >/dev/null 2>&1; then
  DOCKER_BIN=docker.exe
fi

if [ "$1" ]; then
  CONFIG_FILE="$1"
else
  CONFIG_FILE="docker-compose.yml"
fi

# force-navigate to base directory (parent of scripts/ directory)
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "$SCRIPT_PATH/.." >/dev/null 2>&1

unset CONFIRMATION
echo ""
read -p "(Re)generate self-signed certificates for HTTPS access [Y/n]? " CONFIRMATION
CONFIRMATION=${CONFIRMATION:-Y}
if [[ $CONFIRMATION =~ ^[Yy]$ ]]; then
  mkdir -p certs
  pushd ./certs >/dev/null 2>&1
  rm -f *.pem
  /bin/bash ../scripts/gen_self_signed_certs.sh >/dev/null 2>&1
  popd >/dev/null 2>&1
fi

popd >/dev/null 2>&1
