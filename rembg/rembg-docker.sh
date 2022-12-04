#!/usr/bin/env bash

# docker wrapper script for danielgatis/rembg (rembg i)
# https://github.com/danielgatis/rembg

IMAGE="${REMBG_IMAGE:-docker.io/danielgatis/rembg}"
ENGINE="${CONTAINER_ENGINE:-docker}"

ENCODING="utf-8"

while getopts vi:o: opts; do
   case ${opts} in
      v) set -x ;;
      i) IN_FILE=${OPTARG} ;;
      o) OUT_FILE=${OPTARG} ;;
   esac
done
shift "$(($OPTIND -1))"

if [[ -z "${IN_FILE}" ]] || [[ -z "${OUT_FILE}" ]] ; then
  echo "usage:" >&2
  echo "  rembg-docker.sh -i <IN_FILE> -o <OUT_FILE> [-- other rembg options]" >&2
  exit 1
elif [[ ! -f "${IN_FILE}" ]]; then
  echo "usage:" >&2
  echo "  rembg-docker.sh -i <IN_FILE> -o <OUT_FILE> [-- other rembg options]" >&2
  echo "" >&2
  echo "${IN_FILE} does not exist!" >&2
  exit 1
fi

TEMP_DIR=$(mktemp -d -t rembg.XXXXXXXXXX)

function finish {
  rm -rf "${TEMP_DIR}"
}
trap finish EXIT

IN_BASENAME="$(basename "${IN_FILE}")"
OUT_BASENAME="$(basename "${OUT_FILE}")"

cp "${IN_FILE}" "${TEMP_DIR}/"

"${ENGINE}" run --rm \
  -u $([[ "${ENGINE}" == "podman" ]] && echo 0 || id -u):$([[ "${ENGINE}" == "podman" ]] && echo 0 || id -g) \
  -v "${TEMP_DIR}:/data:rw" \
  "${IMAGE}" i "$@" "/data/${IN_BASENAME}" "/data/${OUT_BASENAME}"

cp "${TEMP_DIR}/${OUT_BASENAME}" "${OUT_FILE}"

echo "${OUT_FILE}"
