#!/bin/bash

ENCODING="utf-8"
while getopts i: opts; do
   case ${opts} in
      i) IN_FILE=${OPTARG} ;;
   esac
done

if [[ -z $IN_FILE ]] ; then
  echo "usage:"
  echo "  capa.sh -i <IN_FILE>"
  exit 1
elif [[ ! -f "$IN_FILE" ]]; then
  echo "usage:"
  echo "  capa.sh -i <IN_FILE>"
  echo ""
  echo "$IN_FILE does not exist!"
  exit 1
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
  capa:latest "/data/$IN_BASENAME"
