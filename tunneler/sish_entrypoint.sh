#!/usr/bin/env bash

# sish: SSH-based HTTP tunnel relay, used as a self-hosted tunnel
# provider for ffl (FastFileLink) via --preferred-tunnel.
#
# sish runs HTTP-only here. A reverse proxy (Traefik) terminates TLS
# for *.SISH_DOMAIN and forwards plain HTTP to SISH_HTTP_PORT.
# --proxy-ssl-termination tells sish to advertise https:// URLs to
# connecting clients, which is what ffl's url_pattern looks for.

set -euo pipefail

if [ ! -x /usr/bin/sish ]; then
  echo "sish is not installed in this image" >&2
  exit 1
fi

if [ -z "${SISH_DOMAIN:-}" ]; then
  echo "SISH_DOMAIN must be set (e.g. tun.example.org)" >&2
  exit 1
fi

KEYS_DIR="${SISH_KEYS_DIR:-/var/lib/sish/keys}"
PUBKEYS_DIR="${SISH_PUBKEYS_DIR:-/var/lib/sish/pubkeys}"

# The host key lives in KEYS_DIR. sish generates one on first start if
# none exists. Persist this directory, otherwise clients see a changed
# host key after every container rebuild.
mkdir -p "$KEYS_DIR" 2>/dev/null || true

if [ ! -d "$PUBKEYS_DIR" ] || [ -z "$(ls -A "$PUBKEYS_DIR" 2>/dev/null)" ]; then
  echo "warning: no authorized public keys found in $PUBKEYS_DIR; nobody will be able to open tunnels" >&2
fi

ARGS=(
  --ssh-address=":${SISH_SSH_PORT:-2222}"
  --http-address=":${SISH_HTTP_PORT:-9015}"
  --domain="$SISH_DOMAIN"

  # TLS is terminated by the reverse proxy.
  --https=false
  --proxy-ssl-termination="${SISH_PROXY_SSL_TERMINATION:-true}"
  --https-port-override="${SISH_HTTPS_PORT_OVERRIDE:-443}"
  --http-port-override="${SISH_HTTP_PORT_OVERRIDE:-80}"

  # Public key auth only.
  --authentication=true
  --authentication-password=
  --authentication-keys-directory="$PUBKEYS_DIR"
  --private-keys-directory="$KEYS_DIR"

  # Each share gets an unguessable subdomain. sish's default length is 3.
  --bind-random-subdomains="${SISH_RANDOM_SUBDOMAINS:-true}"
  --bind-random-subdomains-length="${SISH_RANDOM_SUBDOMAIN_LENGTH:-12}"

  # sish's default idle timeout is 5s, which can drop a download while
  # ffl is busy preparing a large folder. Raise it.
  --idle-connection-timeout="${SISH_IDLE_TIMEOUT:-120s}"

  # The HTML templates are only needed for the admin/service consoles,
  # and they aren't shipped in this image.
  --load-templates=false
  --admin-console=false
  --service-console=false

  --log-to-stdout=true
)

if [ -n "${SISH_REDIRECT_ROOT_LOCATION:-}" ]; then
  ARGS+=(--redirect-root=true --redirect-root-location="$SISH_REDIRECT_ROOT_LOCATION")
else
  ARGS+=(--redirect-root=false)
fi

if [ -n "${SISH_PRIVATE_KEY_PASSPHRASE:-}" ]; then
  ARGS+=(--private-key-passphrase="$SISH_PRIVATE_KEY_PASSPHRASE")
fi

# Anything else sish supports can be passed through verbatim.
if [ -n "${SISH_EXTRA_ARGS:-}" ]; then
  read -r -a EXTRA <<< "$SISH_EXTRA_ARGS"
  ARGS+=("${EXTRA[@]}")
fi

exec /usr/bin/sish "${ARGS[@]}"
