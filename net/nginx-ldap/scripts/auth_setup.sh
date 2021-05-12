#!/usr/bin/env bash

if [ -z "$BASH_VERSION" ]; then
  echo "Wrong interpreter, please run \"$0\" with bash"
  exit 1
fi

set -e

# force-navigate to base directory (parent of scripts/ directory)
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "$SCRIPT_PATH/.." >/dev/null 2>&1

USERNAME=""
PASSWORD=""
PASSWORD_CONFIRM=""

read -p "username: " USERNAME
while true; do
    read -s -p "${USERNAME} password: " PASSWORD
    echo
    read -s -p "${USERNAME} password (again): " PASSWORD_CONFIRM
    echo
    [ "$PASSWORD" = "$PASSWORD_CONFIRM" ] && break
    echo "Passwords do not match"
done
PASSWORD_ENCRYPTED="$(echo $PASSWORD | openssl passwd -1 -stdin)"

# get previous username to remove from htpasswd file if it's changed
unset USERNAME_PREVIOUS
[[ -r auth.env ]] && source auth.env && USERNAME_PREVIOUS="$NGINX_USERNAME"

cat <<EOF > auth.env
NGINX_USERNAME=$USERNAME
NGINX_PASSWORD=$PASSWORD_ENCRYPTED
EOF
chmod 600 ./auth.env

pushd ./nginx/ >/dev/null 2>&1
# create or update the htpasswd file
[[ ! -f ./htpasswd ]] && HTPASSWD_CREATE_FLAG="-c" || HTPASSWD_CREATE_FLAG=""
htpasswd -b $HTPASSWD_CREATE_FLAG -B ./htpasswd "$USERNAME" "$PASSWORD" >/dev/null 2>&1

# if the username has changed, remove the previous username from htpasswd
[[ -n "$USERNAME_PREVIOUS" ]] && [ "$USERNAME" != "$USERNAME_PREVIOUS" ] && sed -i "/^$USERNAME_PREVIOUS:/d" ./htpasswd

source ../.ldap_config_defaults 2>/dev/null || true
LDAP_DEFAULT_PROTO=${LDAP_PROTO:-"ldap://"}
LDAP_DEFAULT_HOST=${LDAP_HOST:-"ds.example.com"}
LDAP_DEFAULT_PORT=${LDAP_PORT:-"3268"}
LDAP_DEFAULT_SERVER_TYPE=${LDAP_SERVER_TYPE:-"winldap"}
if [[ "$LDAP_DEFAULT_SERVER_TYPE" = 'openldap' ]]; then
  LDAP_DEFAULT_URI='DC=example,DC=com?uid?sub?(objectClass=posixAccount)'
  LDAP_DEFAULT_GROUP_ATTR=memberuid
else
  LDAP_DEFAULT_URI='DC=example,DC=com?sAMAccountName?sub?(objectClass=person)'
  LDAP_DEFAULT_GROUP_ATTR=member
fi

[[ ! -f nginx_ldap.conf ]] && cat <<EOF > nginx_ldap.conf
# This is a sample configuration for the ldap_server section of nginx.conf.
# Yours will vary depending on how your Active Directory/LDAP server is configured.
# See https://github.com/kvspb/nginx-auth-ldap#available-config-parameters for options.

ldap_server ad_server {
  url "${LDAP_DEFAULT_PROTO}${LDAP_DEFAULT_HOST}:${LDAP_DEFAULT_PORT}/${LDAP_DEFAULT_URI}";

  binddn "bind_dn";
  binddn_passwd "bind_dn_password";

  group_attribute ${LDAP_DEFAULT_GROUP_ATTR};
  group_attribute_is_dn on;
  require group "CN=users,OU=groups,DC=example,DC=com";
  require valid_user;
  satisfy all;
}

auth_ldap_cache_enabled on;
auth_ldap_cache_expiration_time 10000;
auth_ldap_cache_size 1000;
EOF

popd >/dev/null 2>&1

unset CONFIRMATION
echo ""
read -p "(Re)generate self-signed certificates for HTTPS access [Y/n]? " CONFIRMATION
CONFIRMATION=${CONFIRMATION:-Y}
if [[ $CONFIRMATION =~ ^[Yy]$ ]]; then
  pushd ./nginx/certs >/dev/null 2>&1
  rm -f *.pem
  /bin/bash ./gen_self_signed_certs.sh >/dev/null 2>&1
  popd >/dev/null 2>&1
fi

popd >/dev/null 2>&1
