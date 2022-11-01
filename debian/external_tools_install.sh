#!/bin/bash

set -e
set -x

DEB_ARCH=$(dpkg --print-architecture)
LINUX_CPU=$(uname -m)

if [[ $DEB_ARCH == arm* ]]; then
  if [[ $LINUX_CPU == aarch64 ]]; then
    STARSHIP_RELEASE_FILENAME=starship-aarch64-unknown-linux-musl.tar.gz
  else
    STARSHIP_RELEASE_FILENAME=starship-arm-unknown-linux-musleabihf.tar.gz
  fi
else
  STARSHIP_RELEASE_FILENAME=starship-x86_64-unknown-linux-gnu.tar.gz
fi

cd /tmp
curl -o ./starship.tar.gz -sSL "https://github.com/starship/starship/releases/latest/download/$STARSHIP_RELEASE_FILENAME"
tar xf ./starship.tar.gz
mv ./starship /usr/bin/starship
chmod 755 /usr/bin/starship

curl -o ./getcroc.sh -sSL "https://getcroc.schollz.com"
chmod +x ./getcroc.sh
./getcroc.sh -p /usr/bin