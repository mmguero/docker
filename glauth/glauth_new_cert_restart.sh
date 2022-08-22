#!/usr/bin/env bash

set -e
set -o pipefail
set -u

ENCODING="utf-8"

[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
export SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"

pushd "$SCRIPT_PATH"/ >/dev/null 2>&1

sed -i "s/^\([[:space:]]*#[[:space:]]*date\)[[:space:]]*=.*/\1 = $(date +%Y-%m-%dT%H:%M:%S%z)/" \
       "${1:-./glauth.cfg}" && \

systemctl --no-pager --user status glauth && \
  ( systemctl --no-pager --user stop glauth ; sleep 10 ; systemctl --no-pager --user start glauth ) || \
  killall glauth

popd >/dev/null 2>&1
