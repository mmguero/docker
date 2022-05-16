#!/usr/bin/env bash

set -e

RUN_PATH="$(pwd)"
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "$SCRIPT_PATH" >/dev/null 2>&1

for DEST in certs_ldap certs_web; do
  /bin/cp -vf "$HOME"/services/certs/ca.crt \
                "$HOME"/services/certs/ldap.crt \
                "$HOME"/services/certs/ldap.key \
              ./$DEST
done

# docker-compose down || true
# podman-compose down || true
systemctl --user stop openldap

# docker-compose up -d
# podman-compose --podman-run-args '--uidmap 33:0:1 --uidmap 0:1:33 --uidmap 34:34:64536' up -d
systemctl --user start openldap

sleep 20

ldapmodify -D "cn=admin,$(grep LDAP_BASE_DN ./docker-compose.yml | sed "s/[^=]*=//")" -w "$(grep LDAP_ADMIN_PASSWORD ./docker-compose.yml | sed "s/[^=]*=//")" -h 127.0.0.1 -p 389 -a -f ./export.ldif

popd >/dev/null 2>&1
