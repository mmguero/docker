#!/bin/bash

if [ -z "$BASH_VERSION" ]; then
  echo "Wrong interpreter, please run \"$0\" with bash"
  exit 1
fi

set -e

# force-navigate to base directory (parent of scripts/ directory)
RUN_PATH="$(pwd)"
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
if ! (type "$REALPATH" && type "$DIRNAME") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH and $DIRNAME"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"
pushd "$SCRIPT_PATH/.." >/dev/null 2>&1

CURRENT_REV_SHA="$(git rev-parse --short --verify HEAD)"
if [ -z "$CURRENT_REV_SHA" ]; then
  CURRENT_REV_TAG="$(date +%Y.%m.%d_%H:%M:%S)"
else
  CURRENT_REV_DATE="$(git log -1 --format="%at" | xargs -I{} date -d @{} +%Y%m%d_%H%M%S)"
  if [ -z "$CURRENT_REV_DATE" ]; then
    CURRENT_REV_TAG="$(date +%Y.%m.%d_%H:%M:%S)"
  fi
  CURRENT_REV_TAG="${CURRENT_REV_DATE}_${CURRENT_REV_SHA}"
fi

echo "This might take a few minutes..."
DESTNAMEIMAGES="$RUN_PATH/espejo_${CURRENT_REV_TAG}_images.tar.gz"
IMAGES=( $(grep image: $RUN_PATH/docker-compose.yml | awk '{print $2}') )
docker save "${IMAGES[@]}" | gzip > "$DESTNAMEIMAGES"
echo "Packaged espejo docker images to \"$DESTNAMEIMAGES\""
echo ""
