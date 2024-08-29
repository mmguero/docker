#!/bin/bash

# set -e
set -o pipefail
shopt -s nocasematch

ENCODING="utf-8"

[[ -z "$GITHUB_OAUTH_TOKEN" ]] && [[ -n "$GITHUB_TOKEN" ]] && export GITHUB_OAUTH_TOKEN="$GITHUB_TOKEN"

cd /tmp
curl -o ./getcroc.sh -sSL "https://getcroc.schollz.com"
chmod +x ./getcroc.sh
./getcroc.sh -p /usr/bin

DEB_ARCH=$(dpkg --print-architecture)
LINUX_CPU=$(uname -m)

cd /tmp
FETCH_ALT_URL=
if [[ $DEB_ARCH == arm* ]]; then
  if [[ $LINUX_CPU == aarch64 ]]; then
    FETCH_URL="https://github.com/gruntwork-io/fetch/releases/latest/download/fetch_linux_arm64"
  else
    # todo
    false
  fi
else
  FETCH_URL="https://github.com/gruntwork-io/fetch/releases/latest/download/fetch_linux_amd64"
  FETCH_ALT_URL="https://filedn.com/lqGgqyaOApSjKzN216iPGQf/Software/Linux/fetch_linux_amd64"
fi
curl -fsSL -o /tmp/fetch "$FETCH_URL"
chmod 755 /tmp/fetch
if /tmp/fetch --version >/dev/null 2>&1; then
  cp -f /tmp/fetch /usr/bin/fetch
elif [[ -n "$FETCH_ALT_URL" ]]; then
  curl -fsSL -o /usr/bin/fetch "$FETCH_URL"
  chmod 755 /usr/bin/fetch
fi
rm -rf /tmp/fetch

if /usr/bin/fetch --version >/dev/null 2>&1; then
  if [[ "$DEB_ARCH" =~ ^arm ]]; then
    if [[ "$LINUX_CPU" == "aarch64" ]]; then
      ASSETS=(
        "https://github.com/antonmedv/fx|^fx_linux_arm64$|/usr/bin/fx|755"
        "https://github.com/aptible/supercronic|^supercronic-linux-arm64$|/usr/bin/supercronic|755"
        "https://github.com/boringproxy/boringproxy|^boringproxy-linux-arm64$|/usr/bin/boringproxy|755"
        "https://github.com/darkhz/rclone-tui|^rclone-tui_.+_Linux_arm64\.tar\.gz$|/tmp/rclone-tui.tar.gz"
        "https://github.com/eza-community/eza|^eza_aarch64-unknown-linux-gnu\.tar\.gz$|/tmp/eza.tar.gz"
        "https://github.com/FiloSottile/age|^age-v.+-linux-arm64\.tar\.gz$|/tmp/age.tar.gz"
        "https://github.com/gabrie30/ghorg|^ghorg_.+_Linux_arm64\.tar\.gz$|/tmp/ghorg.tar.gz"
        "https://github.com/mikefarah/yq|^yq_linux_arm64$|/usr/bin/yq|755"
        "https://github.com/neilotoole/sq|^sq-.+arm64-arm64\.tar\.gz$|/tmp/sq.tar.gz"
        "https://github.com/nektos/act|^act_Linux_arm64\.tar\.gz$|/tmp/act.tar.gz"
        "https://github.com/peco/peco|^peco_linux_arm64\.tar\.gz$|/tmp/peco.tar.gz"
        "https://github.com/projectdiscovery/httpx|^httpx_.+_linux_arm64\.zip$|/tmp/httpx.zip"
        "https://github.com/pufferffish/wireproxy|^wireproxy_linux_arm64\.tar\.gz$|/tmp/wireproxy.tar.gz"
        "https://github.com/rclone/rclone|^rclone-v.+-linux-arm64\.zip$|/tmp/rclone.zip"
        "https://github.com/sachaos/viddy|^viddy-.+-linux-arm64\.tar\.gz$|/tmp/viddy.tar.gz"
        "https://github.com/schollz/hostyoself|^hostyoself_.+_Linux-ARM64\.tar\.gz$|/tmp/hostyoself.tar.gz"
        "https://github.com/sharkdp/bat|^bat-v.+-aarch64-unknown-linux-gnu\.tar\.gz$|/tmp/bat.tar.gz"
        "https://github.com/sharkdp/fd|^fd-v.+-aarch64-unknown-linux-gnu\.tar\.gz$|/tmp/fd.tar.gz"
        "https://github.com/smallstep/cli|^step_linux_.+_arm64\.tar\.gz$|/tmp/step.tar.gz"
        "https://github.com/starship/starship|^starship-aarch64-unknown-linux-musl\.tar\.gz$|/tmp/starship.tar.gz"
        "https://github.com/tomnomnom/gron|^gron-linux-arm64-.+\.tgz$|/tmp/gron.tgz"
        "https://github.com/wader/fq|^fq_.+_linux_arm64\.tar\.gz$|/tmp/fq.tar.gz"
        "https://github.com/watchexec/watchexec|^watchexec-.+-aarch64-unknown-linux-musl\.tar\.xz$|/tmp/watchexec.tar.xz"
      )
    elif [[ "$LINUX_CPU" == "armv6l" ]]; then
      ASSETS=(
        "https://github.com/aptible/supercronic|^supercronic-linux-arm$|/usr/bin/supercronic|755"
        "https://github.com/boringproxy/boringproxy|^boringproxy-linux-arm$|/usr/bin/boringproxy|755"
        "https://github.com/darkhz/rclone-tui|^rclone-tui_.+_Linux_armv6\.tar\.gz$|/tmp/rclone-tui.tar.gz"
        "https://github.com/eza-community/eza|^eza_arm-unknown-linux-gnueabihf\.tar\.gz$|/tmp/eza.tar.gz"
        "https://github.com/FiloSottile/age|^age-v.+-linux-arm\.tar\.gz$|/tmp/age.tar.gz"
        "https://github.com/mikefarah/yq|^yq_linux_arm$|/usr/bin/yq|755"
        "https://github.com/nektos/act|^act_Linux_armv6\.tar\.gz$|/tmp/act.tar.gz"
        "https://github.com/peco/peco|^peco_linux_arm\.tar\.gz$|/tmp/peco.tar.gz"
        "https://github.com/projectdiscovery/httpx|^httpx_.+_linux_armv6\.zip$|/tmp/httpx.zip"
        "https://github.com/pufferffish/wireproxy|^wireproxy_linux_arm\.tar\.gz$|/tmp/wireproxy.tar.gz"
        "https://github.com/rclone/rclone|^rclone-v.+-linux-arm\.zip$|/tmp/rclone.zip"
        "https://github.com/schollz/hostyoself|^hostyoself_.+_Linux-ARM\.tar\.gz$|/tmp/hostyoself.tar.gz"
        "https://github.com/sharkdp/bat|^bat-v.+-arm-unknown-linux-musleabihf\.tar\.gz$|/tmp/bat.tar.gz"
        "https://github.com/sharkdp/fd|^fd-v.+-arm-unknown-linux-musleabihf\.tar\.gz$|/tmp/fd.tar.gz"
        "https://github.com/smallstep/cli|^step_linux_.+_armv6\.tar\.gz$|/tmp/step.tar.gz"
        "https://github.com/starship/starship|^starship-arm-unknown-linux-musleabihf\.tar\.gz$|/tmp/starship.tar.gz"
        "https://github.com/watchexec/watchexec|^watchexec-.+-armv7-unknown-linux-gnueabihf\.tar\.xz$|/tmp/watchexec.tar.xz"
      )
    else
      ASSETS=(
        "https://github.com/aptible/supercronic|^supercronic-linux-arm$|/usr/bin/supercronic|755"
        "https://github.com/boringproxy/boringproxy|^boringproxy-linux-arm$|/usr/bin/boringproxy|755"
        "https://github.com/darkhz/rclone-tui|^rclone-tui_.+_Linux_armv7\.tar\.gz$|/tmp/rclone-tui.tar.gz"
        "https://github.com/eza-community/eza|^eza_arm-unknown-linux-gnueabihf\.tar\.gz$|/tmp/eza.tar.gz"
        "https://github.com/FiloSottile/age|^age-v.+-linux-arm\.tar\.gz$|/tmp/age.tar.gz"
        "https://github.com/mikefarah/yq|^yq_linux_arm$|/usr/bin/yq|755"
        "https://github.com/nektos/act|^act_Linux_armv7\.tar\.gz$|/tmp/act.tar.gz"
        "https://github.com/peco/peco|^peco_linux_arm\.tar\.gz$|/tmp/peco.tar.gz"
        "https://github.com/projectdiscovery/httpx|^httpx_.+_linux_armv6\.zip$|/tmp/httpx.zip"
        "https://github.com/pufferffish/wireproxy|^wireproxy_linux_arm\.tar\.gz$|/tmp/wireproxy.tar.gz"
        "https://github.com/rclone/rclone|^rclone-v.+-linux-arm-v7\.zip$|/tmp/rclone.zip"
        "https://github.com/schollz/hostyoself|^hostyoself_.+_Linux-ARM\.tar\.gz$|/tmp/hostyoself.tar.gz"
        "https://github.com/sharkdp/bat|^bat-v.+-arm-unknown-linux-musleabihf\.tar\.gz$|/tmp/bat.tar.gz"
        "https://github.com/sharkdp/fd|^fd-v.+-arm-unknown-linux-musleabihf\.tar\.gz$|/tmp/fd.tar.gz"
        "https://github.com/smallstep/cli|^step_linux_.+_armv7\.tar\.gz$|/tmp/step.tar.gz"
        "https://github.com/starship/starship|^starship-arm-unknown-linux-musleabihf\.tar\.gz$|/tmp/starship.tar.gz"
        "https://github.com/watchexec/watchexec|^watchexec-.+-armv7-unknown-linux-gnueabihf\.tar\.xz$|/tmp/watchexec.tar.xz"
      )
    fi
  else
    ASSETS=(
      "https://github.com/antonmedv/fx|^fx_linux_amd64$|/usr/bin/fx|755"
      "https://github.com/aptible/supercronic|^supercronic-linux-amd64$|/usr/bin/supercronic|755"
      "https://github.com/boringproxy/boringproxy|^boringproxy-linux-x86_64$|/usr/bin/boringproxy|755"
      "https://github.com/darkhz/rclone-tui|^rclone-tui_.+_Linux_x86_64\.tar\.gz$|/tmp/rclone-tui.tar.gz"
      "https://github.com/eza-community/eza|^eza_x86_64-unknown-linux-musl\.tar\.gz$|/tmp/eza.tar.gz"
      "https://github.com/FiloSottile/age|^age-v.+-linux-amd64\.tar\.gz$|/tmp/age.tar.gz"
      "https://github.com/gabrie30/ghorg|^ghorg_.+_Linux_x86_64\.tar\.gz$|/tmp/ghorg.tar.gz"
      "https://github.com/jez/as-tree|^as-tree-.+-linux\.zip$|/tmp/as-tree.zip"
      "https://github.com/mikefarah/yq|^yq_linux_amd64$|/usr/bin/yq|755"
      "https://github.com/neilotoole/sq|^sq-.+amd64-amd64\.tar\.gz$|/tmp/sq.tar.gz"
      "https://github.com/nektos/act|^act_Linux_x86_64\.tar\.gz$|/tmp/act.tar.gz"
      "https://github.com/peco/peco|^peco_linux_amd64\.tar\.gz$|/tmp/peco.tar.gz"
      "https://github.com/projectdiscovery/httpx|^httpx_.+_linux_amd64\.zip$|/tmp/httpx.zip"
      "https://github.com/pufferffish/wireproxy|^wireproxy_linux_amd64\.tar\.gz$|/tmp/wireproxy.tar.gz"
      "https://github.com/rclone/rclone|^rclone-v.+-linux-amd64\.zip$|/tmp/rclone.zip"
      "https://github.com/sachaos/viddy|^viddy-.+-linux-x86_64\.tar\.gz$|/tmp/viddy.tar.gz"
      "https://github.com/schollz/hostyoself|^hostyoself_.+_Linux-64bit\.tar\.gz$|/tmp/hostyoself.tar.gz"
      "https://github.com/sharkdp/bat|^bat-v.+-x86_64-unknown-linux-gnu\.tar\.gz$|/tmp/bat.tar.gz"
      "https://github.com/sharkdp/fd|^fd-v.+-x86_64-unknown-linux-gnu\.tar\.gz$|/tmp/fd.tar.gz"
      "https://github.com/smallstep/cli|^step_linux_.+_amd64\.tar\.gz$|/tmp/step.tar.gz"
      "https://github.com/starship/starship|^starship-x86_64-unknown-linux-gnu\.tar\.gz$|/tmp/starship.tar.gz"
      "https://github.com/timvisee/ffsend|^ffsend-v.+-linux-x64-static$|/usr/bin/ffsend|755"
      "https://github.com/tomnomnom/gron|^gron-linux-amd64-.+\.tgz$|/tmp/gron.tgz"
      "https://github.com/wader/fq|^fq_.+_linux_amd64\.tar\.gz$|/tmp/fq.tar.gz"
      "https://github.com/watchexec/watchexec|^watchexec-.+-x86_64-unknown-linux-musl\.tar\.xz$|/tmp/watchexec.tar.xz"
      "https://github.com/Wilfred/difftastic|^difft-x86_64-unknown-linux-gnu\.tar\.gz$|/tmp/difft.tar.gz"
    )
  fi

  for i in ${ASSETS[@]}; do
    REPO="$(echo "$i" | cut -d'|' -f1)"
    ASSET_REGEX="$(echo "$i" | cut -d'|' -f2)"
    OUTPUT_FILE="$(echo "$i" | cut -d'|' -f3)"
    OUTPUT_FILE_PERMS="$(echo "$i" | cut -d'|' -f4)"
    echo "" >&2
    echo "Downloading asset for $REPO..." >&2
    FETCH_DIR="$(mktemp -d)"
    /usr/bin/fetch --log-level warn \
      --repo="$REPO" \
      --tag=">=0.0.0" \
      --release-asset="$ASSET_REGEX" \
      "$FETCH_DIR"
    mv "$FETCH_DIR"/* "$OUTPUT_FILE"
    rm -rf "$FETCH_DIR"
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
          cut -d: -f 1 | xargs -I XXX -r mv "XXX" /usr/bin/
        rm -rf "$UNPACK_DIR" "$OUTPUT_FILE"
      fi
    fi
  done
else
  echo "Could not download and/or execute fetch"
  rm -f /usr/bin/fetch
  exit 1
fi