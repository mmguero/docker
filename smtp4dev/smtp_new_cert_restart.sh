#!/usr/bin/env bash

set -e
set -u
set -o pipefail

ENCODING="utf-8"

RUN_PATH="$(pwd)"
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (command -v "$REALPATH" && command -v "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"

CERT_DIR=${SRV_CERT_DIR:-"$SCRIPT_PATH"}
OUTPUT_DIR=
KEY_BASE=${SRV_CERT_BASE:-"$(hostname -s)"}
CA_NAME="ca.crt"
EXECUTE_COMMAND=
RESTART_COMPOSE=
RESTART_COMPOSE_FILE=docker-compose.yml

while getopts 'vnd:o:b:a:x:r:f:' OPTION; do
  case "$OPTION" in
    v)
      VERBOSE_FLAG="-v"
      set -x
      ;;

    d)
      CERT_DIR="$OPTARG"
      ;;

    o)
      OUTPUT_DIR="$OPTARG"
      ;;

    b)
      KEY_BASE="$OPTARG"
      ;;

    a)
      CA_NAME="$OPTARG"
      ;;

    x)
      EXECUTE_COMMAND="$OPTARG"
      ;;

    r)
      RESTART_COMPOSE="$OPTARG"
      ;;

    f)
      RESTART_COMPOSE_FILE="$OPTARG"
      ;;

    ?)
      echo "script usage: $(basename $0) [-v (verbose)] [-d <directory containing crt/key files>] [-o <output directory>] [-b <crt/key base name>] [-a <certificate authority crt>] [-r <(podman-compose|docker-compose) if restarting containers>] [-f <compose .yml file if restarting containers>] [-x <command to execute>]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

CRT_NAME="$KEY_BASE.crt"
KEY_NAME="$KEY_BASE.key"
PEM_NAME="$KEY_BASE.pem"

CERT_DIR="$($REALPATH -e "$CERT_DIR")"
OUTPUT_DIR="$($REALPATH -e "$OUTPUT_DIR")"

pushd "$CERT_DIR" >/dev/null 2>&1

if [[ -r "$CRT_NAME" ]] && [[ -r "$KEY_NAME" ]] && [[ -r "$CA_NAME" ]]; then

  cat "$CRT_NAME" "$KEY_NAME" > "$PEM_NAME"
  chmod 600 "$PEM_NAME"

  if [[ -n "$OUTPUT_DIR" ]] && [[ -d "$OUTPUT_DIR" ]]; then
    cp -v "$CRT_NAME" "$KEY_NAME" "$PEM_NAME" "$CA_NAME" "$OUTPUT_DIR"/
  fi

  if [[ -n "$EXECUTE_COMMAND" ]]; then
    $EXECUTE_COMMAND
  fi

  if [[ -n "$RESTART_COMPOSE" ]] && "$RESTART_COMPOSE" --version >/dev/null 2>&1 && [[ -f "$RESTART_COMPOSE_FILE" ]]; then
    pushd "$($DIRNAME $($REALPATH -e "$RESTART_COMPOSE_FILE"))"
    "$RESTART_COMPOSE" down
    # systemd will restart the service
    # "$RESTART_COMPOSE" up -d
  fi

  popd >/dev/null 2>&1

else
  echo "Unable to read CA, certificate and key files" >&2

  popd >/dev/null 2>&1
  exit 1
fi

