#!/usr/bin/env bash

set -e
set -o pipefail

ENCODING="utf-8"

function in_array() {
  local haystack="${1}[@]"
  local needle="${2}"
  for i in "${!haystack}"; do
    if [[ "${i}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

CONF_FILE="/etc/bandersnatch.conf"
PYPI_FILTER_SCRIPT="/usr/local/bin/pypi_filter.py"
PYPI_DB=${PYPI_PROJECT_DB:-"/tmp/pypi.db"}
PYPI_THREADS=${PYPI_REQ_THREADS:-"1"}
PYPI_NO_NET=${PYPI_OFFLINE:-"false"}
KEEP_RELEASES=${LATEST_RELEASE:-"0"}

# blacklist/whitelist is one or the other
if ( [[ -n $WHITELIST_PACKAGE_FILE ]] && [[ -r "$WHITELIST_PACKAGE_FILE" ]] ) && ( ( [[ -n $BLACKLIST_PACKAGE_FILE ]] && [[ -r "$BLACKLIST_PACKAGE_FILE" ]] ) || ( [[ -n $BLACKLIST_REGEX_FILE ]] && [[ -r "$BLACKLIST_REGEX_FILE" ]] ) || [[ -n $BLACKLIST_KEYWORDS ]] || [[ -n $BLACKLIST_CLASSIFIERS ]] ); then
  echo "blacklist and whitelist features cannot be used together" >&2
  exit 1
fi

# copy the host base config file to the bandersnatch conf location
if [[ -n $BASE_CONF_FILE ]] &&  [[ "$BASE_CONF_FILE" != "$CONF_FILE" ]]; then
  if [[ ! -r "$BASE_CONF_FILE" ]]; then
    cp -f "$BASE_CONF_FILE" "$CONF_FILE"
  else
    echo "invalid bandersnatch base configuration file (\$BASE_CONF_FILE: \"$BASE_CONF_FILE\"" >&2
    exit 1
  fi
fi

############################################
# append latest_release
if (( $KEEP_RELEASES > 0 )); then
  echo "[latest_release]" >> "$CONF_FILE"
  echo "keep = $KEEP_RELEASES" >> "$CONF_FILE"
  echo "" >> "$CONF_FILE"
fi

############################################
# append package whitelist
if ( [[ -n $WHITELIST_PACKAGE_FILE ]] && [[ -r "$WHITELIST_PACKAGE_FILE" ]] ); then

    cat << EOF >> "$CONF_FILE"

[whitelist]
packages =
EOF

  cat "$WHITELIST_PACKAGE_FILE" | awk '{$1=$1};1' | sed "s/^/    /" >> "$CONF_FILE"

fi # whitelist plugin section

############################################
# append blacklist section
if [[ -n $BLACKLIST_PLATFORMS ]] || [[ -n $BLACKLIST_KEYWORDS ]] || [[ -n $BLACKLIST_CLASSIFIERS ]] || ( [[ -n $BLACKLIST_PACKAGE_FILE ]] && [[ -r "$BLACKLIST_PACKAGE_FILE" ]] ); then

  cat << EOF >> "$CONF_FILE"

[blacklist]
EOF

  # blacklist platforms
  if [[ -n $BLACKLIST_PLATFORMS ]]; then
    echo "platforms =" >> "$CONF_FILE"
    echo "$BLACKLIST_PLATFORMS" | sed -n 1'p' | tr ';' '\n' | sed 's/^/    /' >> "$CONF_FILE"
    echo "" >> "$CONF_FILE"
  fi

  # build blacklist packages list into temporary file
  TEMP_BLACKIST_FILE="$(mktemp)"

  # first copy blacklisted packages from file if they exist
  if ( [[ -n $BLACKLIST_PACKAGE_FILE ]] && [[ -r "$BLACKLIST_PACKAGE_FILE" ]] ); then
    cp "$BLACKLIST_PACKAGE_FILE" "$TEMP_BLACKIST_FILE"
  fi

  # if blacklisting by keyword/classifier, run pypi filter script to get blacklisted packages
  if ( [[ -n $BLACKLIST_KEYWORDS ]] || [[ -n $BLACKLIST_CLASSIFIERS ]] ) && [[ -r "$PYPI_FILTER_SCRIPT" ]]; then

    KEYWORDS=()
    KEYWORDS_FLAG=""
    if [[ -n $BLACKLIST_KEYWORDS ]]; then
      IFS=";" read -r -a SOURCESPLIT <<< $(echo "$BLACKLIST_KEYWORDS")
      for index in "${!SOURCESPLIT[@]}"; do
        CANDIDATE="${SOURCESPLIT[index]}"
        if ! in_array KEYWORDS "$CANDIDATE"; then
          KEYWORDS+=("${CANDIDATE}")
        fi
      done
    fi
    (( ${#KEYWORDS[@]} > 0 )) && KEYWORDS_FLAG="--keyword"

    CLASSIFIERS=()
    CLASSIFIERS_FLAG=""
    if [[ -n $BLACKLIST_CLASSIFIERS ]]; then
      IFS=";" read -r -a SOURCESPLIT <<< $(echo "$BLACKLIST_CLASSIFIERS")
      for index in "${!SOURCESPLIT[@]}"; do
        CANDIDATE="${SOURCESPLIT[index]}"
        if ! in_array CLASSIFIERS "$CANDIDATE"; then
          CLASSIFIERS+=("${CANDIDATE}")
        fi
      done
    fi
    (( ${#CLASSIFIERS[@]} > 0 )) && CLASSIFIERS_FLAG="--classifier"

    /usr/bin/env python3 "$PYPI_FILTER_SCRIPT" --db "$PYPI_DB" --offline $PYPI_NO_NET --thread $PYPI_THREADS $KEYWORDS_FLAG "${KEYWORDS[@]}" $CLASSIFIERS_FLAG "${CLASSIFIERS[@]}" >> "$TEMP_BLACKIST_FILE"

  fi # BLACKLIST_KEYWORDS or BLACKLIST_CLASSIFIERS

  sort -u "$TEMP_BLACKIST_FILE" | sponge "$TEMP_BLACKIST_FILE"
  sed -i '/^$/d' "$TEMP_BLACKIST_FILE"
  TEMP_BLACKIST_FILE_LINES=$(wc -l "$TEMP_BLACKIST_FILE" | awk '{print $1}')
  if (( $TEMP_BLACKIST_FILE_LINES > 0 )); then
    cat << EOF >> "$CONF_FILE"

packages =
EOF

    cat "$TEMP_BLACKIST_FILE" | awk '{$1=$1};1' | sed "s/^/    /" >> "$CONF_FILE"
    echo "" >> "$CONF_FILE"
  fi

  rm -f "$TEMP_BLACKIST_FILE"

fi # blacklist plugin section

############################################
# append filter regex section
if ( [[ -n $BLACKLIST_REGEX_FILE ]] && [[ -r "$BLACKLIST_REGEX_FILE" ]] ); then

    cat << EOF >> "$CONF_FILE"

[filter_regex]
packages =
EOF

  cat "$BLACKLIST_REGEX_FILE" | awk '{$1=$1};1' | sed "s/^/    /" >> "$CONF_FILE"
  echo "" >> "$CONF_FILE"

fi # filter_regex plugin section

############################################

/usr/local/bin/bandersnatch "$@"