#!/bin/bash

ENCODING="utf-8"

IN_FILE="$1"
if [[ -z $IN_FILE ]] ; then
  echo "usage:"
  echo "  capa.sh <IN_FILE> [capa options]"
  exit 1
elif [[ ! -f "$IN_FILE" ]]; then
  echo "usage:"
  echo "  capa.sh <IN_FILE> [capa options]"
  echo ""
  echo "$IN_FILE does not exist!"
  exit 1
else
  shift
fi

TEMP_DIR=$(mktemp -d -t capa.XXXXXXXXXX)

function finish {
  rm -rf "$TEMP_DIR"
}
trap finish EXIT

IN_BASENAME="$(basename "$IN_FILE")"

cp "$IN_FILE" "$TEMP_DIR/"

docker run --rm -t \
  -v "$TEMP_DIR:/data:rw" \
  mmguero/capa:latest "/data/$IN_BASENAME" "$@"
