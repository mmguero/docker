#!/usr/bin/env bash

[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
if ! command -v "$REALPATH" >/dev/null 2>&1; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH"
  exit 1
fi

ENGINE="${CONTAINER_ENGINE:-docker}"
IMAGE="oci.guero.top/boringproxy:latest"
TRUSTED_CA=""
CERTS_DIR=""
DB_DIR="$(pwd)"
if [[ "$ENGINE" == "podman" ]]; then
  CONTAINER_PUID=0
  CONTAINER_PGID=0
else
  CONTAINER_PUID=$(id -u)
  CONTAINER_PGID=$(id -g)
fi

while getopts 've:i:u:g:d:c:t:' OPTION; do
  case "$OPTION" in
    v)
      VERBOSE_FLAG="-v"
      set -x
      ;;

    e)
      ENGINE="$OPTARG"
      ;;

    i)
      IMAGE="$OPTARG"
      ;;

    u)
      CONTAINER_PUID="$OPTARG"
      ;;

    g)
      CONTAINER_PGID="$OPTARG"
      ;;

    t)
      TRUSTED_CA="$OPTARG"
      ;;

    c)
      CERTS_DIR="$OPTARG"
      ;;

    d)
      DB_DIR="$OPTARG"
      ;;

    ?)
      echo "script usage: $(basename $0) [-v] [-e engine] [-i image] [-u uid] [-g gid] [-d db-dir] [-c cert-dir] [-t trust-ca]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

MOUNT_ARGS=()
ENV_ARGS=()
CERTS_ARGS=()

DB_DIR_FULL="$($REALPATH "${DB_DIR}")"
mkdir -p "${DB_DIR_FULL}"
MOUNT_ARGS+=( -v )
MOUNT_ARGS+=( "${DB_DIR_FULL}:/home/boring/db:rw" )

if [[ -w "${HOME}"/.ssh/authorized_keys ]]; then
  MOUNT_ARGS+=( -v )
  MOUNT_ARGS+=( "${HOME}/.ssh/authorized_keys:/home/boring/.ssh/authorized_keys:rw" )
fi

if [[ -n "${TRUSTED_CA}" ]] && [[ -e "${TRUSTED_CA}" ]]; then
  TRUSTED_CA_FULL="$($REALPATH "${TRUSTED_CA}")"
  MOUNT_ARGS+=( -v )
  MOUNT_ARGS+=( "${TRUSTED_CA_FULL}:${TRUSTED_CA_FULL}:ro" )
  ENV_ARGS+=( -e )
  ENV_ARGS+=( PUSER_CA_TRUST="${TRUSTED_CA_FULL}" )
fi

if [[ -n "${CERTS_DIR}" ]]; then
  mkdir -p "${CERTS_DIR}"
  CERTS_DIR_FULL="$($REALPATH "${CERTS_DIR}")"
  MOUNT_ARGS+=( -v )
  MOUNT_ARGS+=( "${CERTS_DIR_FULL}:/home/boring/certs:rw" )
  CERTS_ARGS+=( -cert-dir )
  CERTS_ARGS+=( /home/boring/certs )
fi

"${ENGINE}" run -i -t --rm \
  -e PUID="${CONTAINER_PUID}" \
  -e PGID="${CONTAINER_PGID}" \
  --network host \
  --workdir /home/boring/db \
  "${MOUNT_ARGS[@]}" \
  "${ENV_ARGS[@]}" \
  "${IMAGE}" "$@" "${CERTS_ARGS[@]}"

