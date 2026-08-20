#!/usr/bin/env bash

set -euo pipefail

if [ ! -x /usr/bin/croc-web ]; then
  echo "croc-web is not installed in this image" >&2
  exit 1
fi

if [ -n "${CROC_WEB_PORTS:-}" ]; then
  PORTS="$CROC_WEB_PORTS"
elif [ "${CROC_PORT_NON_SEQUENTIAL:-false}" == "true" ]; then
  PORTS="${CROC_PORT_LOW:-9009},${CROC_PORT_HIGH:-9013}"
elif [ -n "${CROC_PORT_LOW:-}" ] && [ -n "${CROC_PORT_HIGH:-}" ]; then
  PORTS="$(seq -s , "$CROC_PORT_LOW" "$CROC_PORT_HIGH")"
else
  PORTS="$(seq -s , 9009 9013)"
fi

BIND="${CROC_WEB_BIND:-0.0.0.0:9014}"
RELAYS="${CROC_WEB_RELAYS:-}"
SITE="${CROC_WEB_SITE:-localhost:9014}"
PASS="${CROC_WEB_PASS:-}"
if [ -z "$PASS" ] && { [ "$RELAYS" = "127.0.0.1" ] || [ "$RELAYS" = "localhost" ]; }; then
  PASS="${CROC_PASS:-}"
fi

ARGS=(
  --bind "$BIND"
  --ports "$PORTS"
)

if [ -n "$RELAYS" ]; then
  ARGS+=(--relays "$RELAYS")
fi

if [ -n "$PASS" ]; then
  ARGS+=(--pass "$PASS")
fi

# Stored uploads stay disabled unless CROC_WEB_STORE_DIR is set.
# The corresponding docker-compose.yml settings are included there as
# commented lines so storage can be enabled without changing this script.
if [ -n "${CROC_WEB_STORE_DIR:-}" ]; then
  ARGS+=(
    --store-dir "$CROC_WEB_STORE_DIR"
    --store-max-transfer "${CROC_WEB_STORE_MAX_TRANSFER:-1GiB}"
    --store-quota "${CROC_WEB_STORE_QUOTA:-5GiB}"
    --store-min-free "${CROC_WEB_STORE_MIN_FREE:-512MiB}"
    --store-max-expiration "${CROC_WEB_STORE_MAX_EXPIRATION:-2w}"
  )

  if [ -n "${CROC_WEB_STORE_TRUSTED_PROXIES:-}" ]; then
    IFS=',' read -r -a TRUSTED_PROXIES <<< "$CROC_WEB_STORE_TRUSTED_PROXIES"
    for proxy in "${TRUSTED_PROXIES[@]}"; do
      [ -n "$proxy" ] && ARGS+=(--store-trusted-proxy "$proxy")
    done
  fi
fi

exec /usr/bin/croc-web "${ARGS[@]}" "$SITE"
