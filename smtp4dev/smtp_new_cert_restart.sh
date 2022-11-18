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

while getopts 'vnd:o:b:a:x:' OPTION; do
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

    ?)
      echo "script usage: $(basename $0) [-v (verbose)] [-d <directory containing crt/key files>] [-o <output directory>] [-b <crt/key base name>] [-a <certificate authority crt>" >&2
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

  if [[ -n "$OUTPUT_DIR" ]] && [[ -d "$OUTPUT_DIR" ]]; then
    cp -v "$CRT_NAME" "$KEY_NAME" "$PEM_NAME" "$CA_NAME" "$OUTPUT_DIR"/
  fi

  if [[ -n "$EXECUTE_COMMAND" ]]; then
    $EXECUTE_COMMAND
  fi

  popd >/dev/null 2>&1

else
  echo "Unable to read CA, certificate and key files" >&2

  popd >/dev/null 2>&1
  exit 1
fi
