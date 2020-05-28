#!/bin/bash

set -u
set -o pipefail

ENCODING="utf-8"

export ZEEK_DOCKER_IMAGE=mmguero/zeek:latest

# Not sure how this would actually work on macOS yet since Docker is in a VM, but
# let's assume somehow it magically would at least for plumbing's sake.
[[ "$(uname -s)" = 'Darwin' ]] && REALPATH=grealpath || REALPATH=realpath
[[ "$(uname -s)" = 'Darwin' ]] && DIRNAME=gdirname || DIRNAME=dirname
[[ "$(uname -s)" = 'Darwin' ]] && BASENAME=gbasename || BASENAME=basename
[[ "$(uname -s)" = 'Darwin' ]] && XARGS=gxargs || XARGS=xargs
if ! (type "$REALPATH" && type "$DIRNAME" && type "$BASENAME" && type "$XARGS") > /dev/null; then
  echo "$(basename "${BASH_SOURCE[0]}") requires $REALPATH, $DIRNAME, $BASENAME and $XARGS"
  exit 1
fi
SCRIPT_PATH="$($DIRNAME $($REALPATH -e "${BASH_SOURCE[0]}"))"

# If there are any *.zeek files in the same directory as this script,
# we will use them as additional scripts to pass along to zeek in addition
# to the default "local" policy. However, if any of these files begins
# with "local", then the default "local" policy will not be used.
pushd $SCRIPT_PATH >/dev/null 2>&1
LOCAL_SCRIPT=local
LOCAL_ZEEK_ARGS=()
for LOCAL_ZEEK_FILE in *.zeek; do
  LOCAL_ZEEK_ARG="$($BASENAME "$LOCAL_ZEEK_FILE")"
  LOCAL_ZEEK_ARGS+=( "$LOCAL_ZEEK_ARG" )
  [[ "$LOCAL_ZEEK_ARG" =~ ^local ]] && LOCAL_SCRIPT=
done
popd >/dev/null 2>&1

export REALPATH
export DIRNAME
export BASENAME
export LOCAL_SCRIPT
export LOCAL_ZEEK_ARGS

# process each argument in parallel with xargs (up to $MAX_ZEEK_PROCS or 4 if unspecified)

printf "%s\0" "$@" | $XARGS -0 -n 1 -P ${MAX_ZEEK_PROCS:-4} -I XXX bash -c '
  IN_FLAG=
  ZEEK_EXE=
  IN_MOUNT=
  NETWORK_MODE=
  MOUNT_ARGS=()
  CAP_ARGS=()

  if [[ -f "XXX" ]]; then
    # PCAP file
    ZEEK_EXE="zeek"
    MOUNT_ARGS+=( -v )
    MOUNT_ARGS+=( "$($DIRNAME $($REALPATH -e "XXX")):/data:ro" )
    IN_FLAG="-r "/data/$($BASENAME "XXX")""

  elif [[ "$(uname -s)" = "Darwin" ]] && ( networksetup -listallhardwareports | grep -q "^Device: XXX" ); then
    # macOS and this is an interface (ignoring the whole docker-in-a-VM issue)
    IN_FLAG="-i XXX"
    ZEEK_EXE="zeekcap"
    CAP_ARGS=(--cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=IPC_LOCK)
    NETWORK_MODE="--network host"

  elif [[ -e /sys/class/net/"XXX" ]]; then
    # Linux and this is an interface
    IN_FLAG="-i XXX"
    ZEEK_EXE="zeekcap"
    CAP_ARGS=(--cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=IPC_LOCK)
    NETWORK_MODE="--network host"

  else
    # what is this?
    echo "Unable to determine type of input argument \"XXX\"" >&2
    exit 1
  fi

  # create a read-only mount for each local zeek script
  for LOCAL_ZEEK_ARG in "${LOCAL_ZEEK_ARGS[@]}"; do
    MOUNT_ARGS+=( -v )
    MOUNT_ARGS+=( "$SCRIPT_PATH/$LOCAL_ZEEK_ARG:/opt/zeek/share/zeek/site/$LOCAL_ZEEK_ARG:ro" )
  done

  # each instance of zeek will write to its own log directory
  LOG_DIR="$(pwd)/$($BASENAME "XXX")"_logs
  mkdir -p "$LOG_DIR"
  MOUNT_ARGS+=( -v )
  MOUNT_ARGS+=( "$LOG_DIR":/zeek-logs )

  # run zeek in docker on the provided input
  docker run --rm $NETWORK_MODE "${CAP_ARGS[@]}" "${MOUNT_ARGS[@]}" $ZEEK_DOCKER_IMAGE \
    $ZEEK_EXE -C $IN_FLAG $LOCAL_SCRIPT "${LOCAL_ZEEK_ARGS[@]}"
'
