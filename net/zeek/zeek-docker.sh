#!/bin/bash

set -u
set -o pipefail
shopt -s nullglob

ENCODING="utf-8"

function join_by { local IFS="$1"; shift; echo "$*"; }

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
LOCAL_ZEEK_SCRIPTS=()
for FILE in *.zeek; do
  if [[ -r "$FILE" ]]; then
    LOCAL_ZEEK_SCRIPT="$($BASENAME "$FILE")"
    LOCAL_ZEEK_SCRIPTS+=( "$LOCAL_ZEEK_SCRIPT" )
    [[ "$LOCAL_ZEEK_SCRIPT" =~ ^local ]] && LOCAL_SCRIPT=
  fi
done
popd >/dev/null 2>&1

export REALPATH
export DIRNAME
export BASENAME
export SCRIPT_PATH
export LOCAL_SCRIPT
export LOCAL_ZEEK_ARGV="$(join_by ':' "${LOCAL_ZEEK_SCRIPTS[@]}")"
export DEFAULT_UID=$(id -u)
export DEFAULT_GID=$(id -g)

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
  IFS=":" read -r -a ZEEK_PARAMS <<< "$LOCAL_ZEEK_ARGV"
  for ZEEK_PARAM in "${ZEEK_PARAMS[@]}"; do
    MOUNT_ARGS+=( -v )
    MOUNT_ARGS+=( "$SCRIPT_PATH/$ZEEK_PARAM:/opt/zeek/share/zeek/site/$ZEEK_PARAM:ro" )
  done

  # each instance of zeek will write to its own log directory
  LOG_DIR="$(pwd)/$($BASENAME "XXX")"_logs
  mkdir -p "$LOG_DIR"
  MOUNT_ARGS+=( -v )
  MOUNT_ARGS+=( "$LOG_DIR":/zeek-logs )

  # run zeek in docker on the provided input
  docker run --rm $NETWORK_MODE -e DEFAULT_UID=$DEFAULT_UID -e DEFAULT_GID=$DEFAULT_GID \
    "${CAP_ARGS[@]}" "${MOUNT_ARGS[@]}" $ZEEK_DOCKER_IMAGE \
    $ZEEK_EXE -C $IN_FLAG $LOCAL_SCRIPT "${ZEEK_PARAMS[@]}"
'
