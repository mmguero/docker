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

echo ""
LDAP_DEFAULT_SERVER_TYPE=${LDAP_SERVER_TYPE:-""}
while [[ $LDAP_DEFAULT_SERVER_TYPE != "openldap" ]] && [[ $LDAP_DEFAULT_SERVER_TYPE != "winldap" ]]; do
  read -p "openldap or winldap: " LDAP_DEFAULT_SERVER_TYPE
done
LDAP_DEFAULT_PROTO=${LDAP_PROTO:-"ldap://"}
LDAP_DEFAULT_HOST=${LDAP_HOST:-"ds.example.com"}
LDAP_DEFAULT_PORT=${LDAP_PORT:-"3268"}
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
# See https://github.com/mmguero-dev/nginx-auth-ldap#available-config-parameters for options.

ldap_server ad_server {
  url "${LDAP_DEFAULT_PROTO}${LDAP_DEFAULT_HOST}:${LDAP_DEFAULT_PORT}/${LDAP_DEFAULT_URI}";

  binddn "bind_dn";
  binddn_passwd "bind_dn_password";

  referral off;

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

unset CONFIRMATION
echo ""
read -p "(Re)generate internal passwords for netbox [Y/n]? " CONFIRMATION
CONFIRMATION=${CONFIRMATION:-Y}
if [[ $CONFIRMATION =~ ^[Yy]$ ]]; then
  pushd ./netbox/env >/dev/null 2>&1
  POSTGRES_PASSWORD="$(LC_ALL=C tr -dc 'A-Za-z0-9_' </dev/urandom | head -c 16 ; echo)"
  REDIS_CACHE_PASSWORD="$(LC_ALL=C tr -dc 'A-Za-z0-9_' </dev/urandom | head -c 16 ; echo)"
  REDIS_PASSWORD="$(LC_ALL=C tr -dc 'A-Za-z0-9_' </dev/urandom | head -c 16 ; echo)"
  SECRET_KEY="$(LC_ALL=C tr -dc 'A-Za-z0-9$%&()*+,-.:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 50 ; echo)"
  SUPERUSER_API_TOKEN="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 40 ; echo)"
  cat <<EOF > postgres.env
POSTGRES_DB=netbox
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_USER=netbox
EOF
  cat <<EOF > redis-cache.env
REDIS_PASSWORD=${REDIS_CACHE_PASSWORD}
EOF
  cat <<EOF > redis.env
REDIS_PASSWORD=${REDIS_PASSWORD}
EOF
  [[ ! -f ./netbox.env ]] && [[ -f ./netbox.env.example ]] && cp ./netbox.env.example ./netbox.env
  sed -i "s/^\(DB_PASSWORD=\).*/\1${POSTGRES_PASSWORD}/" ./netbox.env
  sed -i "s/^\(REDIS_CACHE_PASSWORD=\).*/\1${REDIS_CACHE_PASSWORD}/" ./netbox.env
  sed -i "s/^\(REDIS_PASSWORD=\).*/\1${REDIS_PASSWORD}/" ./netbox.env
  sed -i "s/^\(SECRET_KEY=\).*/\1${SECRET_KEY}/" ./netbox.env
  sed -i "s/^\(SUPERUSER_API_TOKEN=\).*/\1${SUPERUSER_API_TOKEN}/" ./netbox.env
  popd >/dev/null 2>&1
fi

popd >/dev/null 2>&1
