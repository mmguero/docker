#!/usr/bin/env bash

# force-navigate to script directory (containing docker-compose.yml)
RUN_PATH="$(pwd)"
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "$SCRIPT_PATH" >/dev/null 2>&1

# set up booksonic LDAP configuration
for file in /usr/local/share/ca-certificates/*.crt; do docker cp "$file" booksonic:/usr/local/share/ca-certificates/; done

docker-compose exec booksonic bash -c 'for file in /usr/local/share/ca-certificates/*.crt; do keytool -importcert -file "$file" -alias "($(basename "$file" | sed "s/\.crt//")" -keystore /usr/lib/jvm/java-8-openjdk-armhf/jre/lib/security/cacerts -keypass changeit -storepass changeit -noprompt; done; kill $(pidof java)'

popd >/dev/null 2>&1

