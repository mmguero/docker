#!/bin/bash

set -e
set -o pipefail
shopt -s nocasematch

ENCODING="utf-8"

function git_latest_release () {
  if [[ -n "$1" ]]; then
    GITHUB_API_CURL_ARGS=()
    GITHUB_API_CURL_ARGS+=( -fsSL )
    GITHUB_API_CURL_ARGS+=( -H )
    GITHUB_API_CURL_ARGS+=( "Accept: application/vnd.github.v3+json" )
    [[ -n "$GITHUB_TOKEN" ]] && \
      GITHUB_API_CURL_ARGS+=( -H ) && \
      GITHUB_API_CURL_ARGS+=( "Authorization: token $GITHUB_TOKEN" )
    (set -o pipefail && curl "${GITHUB_API_CURL_ARGS[@]}" "https://api.github.com/repos/$1/releases/latest" | jq '.tag_name' | sed -e 's/^"//' -e 's/"$//' ) || \
      (set -o pipefail && curl "${GITHUB_API_CURL_ARGS[@]}" "https://api.github.com/repos/$1/releases" | jq '.[0].tag_name' | sed -e 's/^"//' -e 's/"$//' ) || \
      echo unknown
  else
    echo unknown>&2
  fi
}

set -x

cd /tmp
curl -o ./getcroc.sh -sSL "https://getcroc.schollz.com"
chmod +x ./getcroc.sh
./getcroc.sh -p /usr/bin

DEB_ARCH=$(dpkg --print-architecture)
LINUX_CPU=$(uname -m)

DRA_RELEASE="$(git_latest_release devmatteini/dra)"
cd /tmp
mkdir ./dra
DRA_ALT_URL=
if [[ $DEB_ARCH == arm* ]]; then
  if [[ $LINUX_CPU == aarch64 ]]; then
    DRA_URL="https://github.com/devmatteini/dra/releases/download/${DRA_RELEASE}/dra-${DRA_RELEASE}-aarch64-unknown-linux-gnu.tar.gz"
  else
    DRA_URL="https://github.com/devmatteini/dra/releases/download/${DRA_RELEASE}/dra-${DRA_RELEASE}-arm-unknown-linux-gnueabihf.tar.gz"
  fi
else
  DRA_URL="https://github.com/devmatteini/dra/releases/download/${DRA_RELEASE}/dra-${DRA_RELEASE}-x86_64-unknown-linux-musl.tar.gz"
  DRA_ALT_URL="https://filedn.com/lqGgqyaOApSjKzN216iPGQf/Software/Linux/dra_Linux_x86_64"
fi
curl -sSL "$DRA_URL" | tar xzf - -C ./dra --strip-components 1
chmod 755 /tmp/dra/dra
if /tmp/dra/dra --version >/dev/null 2>&1; then
  cp -f /tmp/dra/dra /usr/bin/dra
elif [[ -n "$DRA_ALT_URL" ]]; then
  curl -sSL -o /usr/bin/dra "$DRA_ALT_URL"
  chmod 755 /usr/bin/dra
fi
rm -rf /tmp/dra

if /usr/bin/dra --version >/dev/null 2>&1; then
  if [[ "$DEB_ARCH" =~ ^arm ]]; then
    if [[ "$LINUX_CPU" == "aarch64" ]]; then
      ASSETS=(
        "aptible/supercronic|supercronic-linux-arm64|/usr/bin/supercronic|755"
        "boringproxy/boringproxy|boringproxy-linux-arm64|/usr/bin/boringproxy|755"
        "darkhz/rclone-tui|rclone-tui_{tag}_Linux_arm64.tar.gz|/tmp/rclone-tui.tar.gz"
        "FiloSottile/age|age-v{tag}-linux-arm64.tar.gz|/tmp/age.tar.gz"
        "gabrie30/ghorg|ghorg_{tag}_Linux_arm64.tar.gz|/tmp/ghorg.tar.gz"
        "mikefarah/yq|yq_linux_arm64|/usr/bin/yq|755"
        "neilotoole/sq|sq-{tag}-linux-arm64.tar.gz|/tmp/sq.tar.gz"
        "nektos/act|act_Linux_arm64.tar.gz|/tmp/act.tar.gz"
        "ogham/exa|exa-linux-armv7-v{tag}.zip|/tmp/exa.zip"
        "peco/peco|peco_linux_arm64.tar.gz|/tmp/peco.tar.gz"
        "projectdiscovery/httpx|httpx_{tag}_linux_arm64.zip|/tmp/httpx.zip"
        "rclone/rclone|rclone-v{tag}-linux-arm64.zip|/tmp/rclone.zip"
        "sachaos/viddy|viddy_{tag}_Linux_arm64.tar.gz|/tmp/viddy.tar.gz"
        "sharkdp/bat|bat-v{tag}-aarch64-unknown-linux-gnu.tar.gz|/tmp/bat.tar.gz"
        "sharkdp/fd|fd-v{tag}-aarch64-unknown-linux-gnu.tar.gz|/tmp/fd.tar.gz"
        "smallstep/cli|step_linux_{tag}_arm64.tar.gz|/tmp/step.tar.gz"
        "starship/starship|starship-aarch64-unknown-linux-musl.tar.gz|/tmp/starship.tar.gz"
        "tomnomnom/gron|gron-linux-arm64-{tag}.tgz|/tmp/gron.tgz"
        "wader/fq|fq_{tag}_linux_arm64.tar.gz|/tmp/fq.tar.gz"
        "watchexec/watchexec|watchexec-{tag}-aarch64-unknown-linux-musl.tar.xz|/tmp/watchexec.tar.xz"
      )
    elif [[ "$LINUX_CPU" == "armv6l" ]]; then
      ASSETS=(
        "aptible/supercronic|supercronic-linux-arm|/usr/bin/supercronic|755"
        "boringproxy/boringproxy|boringproxy-linux-arm|/usr/bin/boringproxy|755"
        "darkhz/rclone-tui|rclone-tui_{tag}_Linux_armv6.tar.gz|/tmp/rclone-tui.tar.gz"
        "FiloSottile/age|age-v{tag}-linux-arm.tar.gz|/tmp/age.tar.gz"
        "mikefarah/yq|yq_linux_arm|/usr/bin/yq|755"
        "nektos/act|act_Linux_armv6.tar.gz|/tmp/act.tar.gz"
        "ogham/exa|exa-linux-armv7-v{tag}.zip|/tmp/exa.zip"
        "peco/peco|peco_linux_arm.tar.gz|/tmp/peco.tar.gz"
        "projectdiscovery/httpx|httpx_{tag}_linux_armv6.zip|/tmp/httpx.zip"
        "rclone/rclone|rclone-v{tag}-linux-arm.zip|/tmp/rclone.zip"
        "sachaos/viddy|viddy_{tag}_Linux_armv6.tar.gz|/tmp/viddy.tar.gz"
        "sharkdp/bat|bat-v{tag}-arm-unknown-linux-musleabihf.tar.gz|/tmp/bat.tar.gz"
        "sharkdp/fd|fd-v{tag}-arm-unknown-linux-musleabihf.tar.gz|/tmp/fd.tar.gz"
        "smallstep/cli|step_linux_{tag}_armv6.tar.gz|/tmp/step.tar.gz"
        "starship/starship|starship-arm-unknown-linux-musleabihf.tar.gz|/tmp/starship.tar.gz"
        "watchexec/watchexec|watchexec-{tag}-armv7-unknown-linux-gnueabihf.tar.xz|/tmp/watchexec.tar.xz"
      )
    else
      ASSETS=(
        "aptible/supercronic|supercronic-linux-arm|/usr/bin/supercronic|755"
        "boringproxy/boringproxy|boringproxy-linux-arm|/usr/bin/boringproxy|755"
        "darkhz/rclone-tui|rclone-tui_{tag}_Linux_armv7.tar.gz|/tmp/rclone-tui.tar.gz"
        "FiloSottile/age|age-v{tag}-linux-arm.tar.gz|/tmp/age.tar.gz"
        "mikefarah/yq|yq_linux_arm|/usr/bin/yq|755"
        "nektos/act|act_Linux_armv7.tar.gz|/tmp/act.tar.gz"
        "ogham/exa|exa-linux-armv7-v{tag}.zip|/tmp/exa.zip"
        "peco/peco|peco_linux_arm.tar.gz|/tmp/peco.tar.gz"
        "projectdiscovery/httpx|httpx_{tag}_linux_armv6.zip|/tmp/httpx.zip"
        "rclone/rclone|rclone-v{tag}-linux-arm-v7.zip|/tmp/rclone.zip"
        "sachaos/viddy|viddy_{tag}_Linux_armv6.tar.gz|/tmp/viddy.tar.gz"
        "sharkdp/bat|bat-v{tag}-arm-unknown-linux-musleabihf.tar.gz|/tmp/bat.tar.gz"
        "sharkdp/fd|fd-v{tag}-arm-unknown-linux-musleabihf.tar.gz|/tmp/fd.tar.gz"
        "smallstep/cli|step_linux_{tag}_armv7.tar.gz|/tmp/step.tar.gz"
        "starship/starship|starship-arm-unknown-linux-musleabihf.tar.gz|/tmp/starship.tar.gz"
        "watchexec/watchexec|watchexec-{tag}-armv7-unknown-linux-gnueabihf.tar.xz|/tmp/watchexec.tar.xz"
      )
    fi
  else
    ASSETS=(
      "aptible/supercronic|supercronic-linux-amd64|/usr/bin/supercronic|755"
      "boringproxy/boringproxy|boringproxy-linux-x86_64|/usr/bin/boringproxy|755"
      "darkhz/rclone-tui|rclone-tui_{tag}_Linux_x86_64.tar.gz|/tmp/rclone-tui.tar.gz"
      "FiloSottile/age|age-v{tag}-linux-amd64.tar.gz|/tmp/age.tar.gz"
      "gabrie30/ghorg|ghorg_{tag}_Linux_x86_64.tar.gz|/tmp/ghorg.tar.gz"
      "jez/as-tree|as-tree-{tag}-linux.zip|/tmp/as-tree.zip"
      "mikefarah/yq|yq_linux_amd64|/usr/bin/yq|755"
      "neilotoole/sq|sq-{tag}-linux-amd64.tar.gz|/tmp/sq.tar.gz"
      "nektos/act|act_Linux_x86_64.tar.gz|/tmp/act.tar.gz"
      "ogham/exa|exa-linux-x86_64-v{tag}.zip|/tmp/exa.zip"
      "peco/peco|peco_linux_amd64.tar.gz|/tmp/peco.tar.gz"
      "projectdiscovery/httpx|httpx_{tag}_linux_amd64.zip|/tmp/httpx.zip"
      "rclone/rclone|rclone-v{tag}-linux-amd64.zip|/tmp/rclone.zip"
      "sachaos/viddy|viddy_{tag}_Linux_x86_64.tar.gz|/tmp/viddy.tar.gz"
      "sharkdp/bat|bat-v{tag}-x86_64-unknown-linux-gnu.tar.gz|/tmp/bat.tar.gz"
      "sharkdp/fd|fd-v{tag}-x86_64-unknown-linux-gnu.tar.gz|/tmp/fd.tar.gz"
      "smallstep/cli|step_linux_{tag}_amd64.tar.gz|/tmp/step.tar.gz"
      "starship/starship|starship-x86_64-unknown-linux-gnu.tar.gz|/tmp/starship.tar.gz"
      "timvisee/ffsend|ffsend-v{tag}-linux-x64-static|/usr/bin/ffsend|755"
      "tomnomnom/gron|gron-linux-amd64-{tag}.tgz|/tmp/gron.tgz"
      "wader/fq|fq_{tag}_linux_amd64.tar.gz|/tmp/fq.tar.gz"
      "watchexec/watchexec|watchexec-{tag}-x86_64-unknown-linux-musl.tar.xz|/tmp/watchexec.tar.xz"
      "Wilfred/difftastic|difft-x86_64-unknown-linux-gnu.tar.gz|/tmp/difft.tar.gz"
    )
  fi

  for i in ${ASSETS[@]}; do
    REPO="$(echo "$i" | cut -d'|' -f1)"
    UNTAG="$(echo "$i" | cut -d'|' -f2)"
    OUTPUT_FILE="$(echo "$i" | cut -d'|' -f3)"
    OUTPUT_FILE_PERMS="$(echo "$i" | cut -d'|' -f4)"
    echo "Downloading asset for $REPO..." >&2
    /usr/bin/dra download \
      -s "$UNTAG" \
      -o "$OUTPUT_FILE" \
      "$REPO"
    if [[ -f "$OUTPUT_FILE" ]]; then
      chmod "${OUTPUT_FILE_PERMS:-644}" "$OUTPUT_FILE"
      if [[ "$OUTPUT_FILE" == *.tar.gz ]] || [[ "$OUTPUT_FILE" == *.tgz ]]; then
        UNPACK_DIR="$(mktemp -d)"
        tar xzf "$OUTPUT_FILE" -C "$UNPACK_DIR"
      elif [[ "$OUTPUT_FILE" == *.tar.xz ]] || [[ "$OUTPUT_FILE" == *.xz ]]; then
        UNPACK_DIR="$(mktemp -d)"
        tar xJf "$OUTPUT_FILE" -C "$UNPACK_DIR" --strip-components 1
      elif [[ "$OUTPUT_FILE" == *.zip ]]; then
        UNPACK_DIR="$(mktemp -d)"
        unzip -q "$OUTPUT_FILE" -d "$UNPACK_DIR"
      else
        UNPACK_DIR=
      fi
      if [[ -d "$UNPACK_DIR" ]]; then
        find "$UNPACK_DIR" -type f -exec file --mime-type "{}" \; | \
          grep -P ":\s+application/.*executable" | \
          cut -d: -f 1 | xargs -I XXX -r mv -v "XXX" /usr/bin/
        rm -rf "$UNPACK_DIR" "$OUTPUT_FILE"
      fi
    fi
  done
else
  echo "Could not download and/or execute dra"
  rm -f /usr/bin/dra
  exit 1
fi