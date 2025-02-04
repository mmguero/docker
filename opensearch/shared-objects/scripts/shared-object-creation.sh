#!/bin/bash

set -euo pipefail
shopt -s nocasematch

DASHB_URL=${DASHBOARDS_URL:-"https://localhost:5601"}
INDEX_PATTERN=${DEFAULT_INDEX_PATTERN:-"ecs-*"}
TEMPLATE_NAME=${DEFAULT_TEMPLATE_NAME:-"ecs_template"}
INDEX_TIME_FIELD=${INDEX_TIME_FIELD:-"@timestamp"}
DARK_MODE=${DASHBOARDS_DARKMODE:-"true"}

TEMPLATES_DIR="/opt/templates"
TEMPLATE_FILE_ORIG="$TEMPLATES_DIR/$TEMPLATE_NAME.json"
TEMPLATE_FILE="/data/init/$TEMPLATE_NAME.json"

STARTUP_IMPORT_PERFORMED_FILE=/tmp/shared-objects-created

if [[ -n "$OPENSEARCH_HOSTS" ]]; then
  readarray -t OPENSEARCH_ARRAY < <(echo "$OPENSEARCH_HOSTS" | jq -r '.[]')
  OPENSEARCH_URL_TO_USE="${OPENSEARCH_ARRAY[0]}"
else
  OPENSEARCH_URL_TO_USE="http://opensearch-node1:9200"
fi

OPENSEARCH_CREDS_CONFIG_FILE_TO_USE=${OPENSEARCH_CREDS_CONFIG_FILE:-"/var/local/curlrc/.creds.curlrc"}
if [[ -r "$OPENSEARCH_CREDS_CONFIG_FILE_TO_USE" ]]; then
  CURL_CONFIG_PARAMS=(
    --config
    "$OPENSEARCH_CREDS_CONFIG_FILE_TO_USE"
    )
else
  CURL_CONFIG_PARAMS=()
fi

DASHBOARDS_URI_PATH="opensearch-dashboards"
XSRF_HEADER="osd-xsrf"
ECS_TEMPLATES_DIR=/opt/ecs-templates-os

# is the Dashboards process server up and responding to requests?
if curl "${CURL_CONFIG_PARAMS[@]}" -fsSL -XGET "$DASHB_URL/api/status" ; then

  #############################################################################################################################
  # Templates
  #   - a sha256 sum of the combined templates is calculated and the templates are imported if the previously stored hash
  #     (if any) does not match the files we see currently.

  TEMPLATES_IMPORTED=false
  TEMPLATES_IMPORT_DIR="$(mktemp -d -t templates-XXXXXX)"
  rsync -a "$TEMPLATES_DIR"/ "$TEMPLATES_IMPORT_DIR"/
  TEMPLATE_FILE_ORIG_TMP="$(echo "$TEMPLATE_FILE_ORIG" | sed "s@$TEMPLATES_DIR@$TEMPLATES_IMPORT_DIR@")"

  # calculate combined SHA sum of all templates to save as _meta.hash to determine if
  # we need to do this import
  TEMPLATE_HASH="$(find "$ECS_TEMPLATES_DIR"/composable "$TEMPLATES_IMPORT_DIR" -type f -name "*.json" -size +2c 2>/dev/null | sort | xargs -r cat | sha256sum | awk '{print $1}')"

  # get the previous stored template hash (if any) to avoid importing if it's already been imported
  set +e
  TEMPLATE_HASH_OLD="$(curl "${CURL_CONFIG_PARAMS[@]}" -fsSL -XGET -H "Content-Type: application/json" "$OPENSEARCH_URL_TO_USE/_index_template/$TEMPLATE_NAME" 2>/dev/null | jq --raw-output ".index_templates[]|select(.name==\"$TEMPLATE_NAME\")|.index_template._meta.hash" 2>/dev/null)"
  set -e

  # proceed only if the current template HASH doesn't match the previously imported one, or if there
  # was an error calculating or storing either
  if [[ "$TEMPLATE_HASH" != "$TEMPLATE_HASH_OLD" ]] || [[ -z "$TEMPLATE_HASH_OLD" ]] || [[ -z "$TEMPLATE_HASH" ]]; then

    if [[ -d "$ECS_TEMPLATES_DIR"/composable/component ]]; then
      echo "Importing ECS composable templates..."
      for i in "$ECS_TEMPLATES_DIR"/composable/component/*.json; do
        TEMP_BASENAME="$(basename "$i")"
        TEMP_FILENAME="${TEMP_BASENAME%.*}"
        echo "Importing ECS composable template $TEMP_FILENAME ..."
        curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL -XPOST -H "Content-Type: application/json" \
          "$OPENSEARCH_URL_TO_USE/_component_template/ecs_$TEMP_FILENAME" -d "@$i" 2>&1
      done
    fi

    if [[ -d "$TEMPLATES_IMPORT_DIR"/composable/component ]]; then
      echo "Importing custom ECS composable templates..."
      for i in "$TEMPLATES_IMPORT_DIR"/composable/component/*.json; do
        TEMP_BASENAME="$(basename "$i")"
        TEMP_FILENAME="${TEMP_BASENAME%.*}"
        echo "Importing custom ECS composable template $TEMP_FILENAME ..."
        curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL -XPOST -H "Content-Type: application/json" \
          "$OPENSEARCH_URL_TO_USE/_component_template/custom_$TEMP_FILENAME" -d "@$i" 2>&1
      done
    fi

    echo "Importing $TEMPLATE_NAME ($TEMPLATE_HASH)..."

    if [[ -f "$TEMPLATE_FILE_ORIG_TMP" ]] && [[ ! -f "$TEMPLATE_FILE" ]]; then
      cp "$TEMPLATE_FILE_ORIG_TMP" "$TEMPLATE_FILE"
    fi

    # store the TEMPLATE_HASH we calculated earlier as the _meta.hash for the ecs template
    TEMPLATE_FILE_TEMP="$(mktemp)"
    ( jq "._meta.hash=\"$TEMPLATE_HASH\"" "$TEMPLATE_FILE" >"$TEMPLATE_FILE_TEMP" 2>/dev/null ) && \
      [[ -s "$TEMPLATE_FILE_TEMP" ]] && \
      cp -f "$TEMPLATE_FILE_TEMP" "$TEMPLATE_FILE" && \
      rm -f "$TEMPLATE_FILE_TEMP"

    # load ecs_template containing field type mappings
    curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL -XPOST -H "Content-Type: application/json" \
      "$OPENSEARCH_URL_TO_USE/_index_template/$TEMPLATE_NAME" -d "@$TEMPLATE_FILE" 2>&1

    # import other templates as well
    for i in "$TEMPLATES_IMPORT_DIR"/*.json; do
      TEMP_BASENAME="$(basename "$i")"
      TEMP_FILENAME="${TEMP_BASENAME%.*}"
      if [[ "$TEMP_FILENAME" != "$TEMPLATE_NAME" ]]; then
        echo "Importing template \"$TEMP_FILENAME\"..."
        curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL -XPOST -H "Content-Type: application/json" \
          "$OPENSEARCH_URL_TO_USE/_index_template/$TEMP_FILENAME" -d "@$i" 2>&1
      fi
    done

    TEMPLATES_IMPORTED=true

  else
    echo "$TEMPLATE_NAME ($TEMPLATE_HASH) already exists at \"${OPENSEARCH_URL_TO_USE}\""
  fi # TEMPLATE_HASH check

  rm -rf "${TEMPLATES_IMPORT_DIR}"

  # end Templates
  #############################################################################################################################

  #############################################################################################################################
  # Index pattern(s)
  #   - Only set overwrite=true if we actually updated the templates above, otherwise overwrite=false and fail silently
  #     if they already exist (http result code 409)
  echo "Importing index pattern..."

  # Create index pattern
  INDEX_PATTERN_FILE_TEMP="$(mktemp)"
  echo "{\"attributes\":{\"title\":\"$INDEX_PATTERN\",\"timeFieldName\":\"$INDEX_TIME_FIELD\"}}" > "$INDEX_PATTERN_FILE_TEMP"
  echo "Creating index pattern \"$INDEX_PATTERN\"..."
  curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL -XPOST -H "Content-Type: application/json" -H "$XSRF_HEADER: anything" \
    "$DASHB_URL/api/saved_objects/index-pattern/${INDEX_PATTERN}?overwrite=${TEMPLATES_IMPORTED}" \
    -d @"$INDEX_PATTERN_FILE_TEMP" 2>&1
  rm -f "$INDEX_PATTERN_FILE_TEMP"

  echo "Setting default index pattern..."

  # Make it the default index
  curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL -XPOST -H "Content-Type: application/json" -H "$XSRF_HEADER: anything" \
    "$DASHB_URL/api/$DASHBOARDS_URI_PATH/settings/defaultIndex" \
    -d"{\"value\":\"$INDEX_PATTERN\"}"

  # end Index pattern
  #############################################################################################################################

  #############################################################################################################################
  # OpenSearch Tweaks
  #   - TODO: only do these if they've NEVER been done before?
  echo "Updating UI settings..."

  # set dark theme (or not)
  [[ "$DARK_MODE" == "true" ]] && DARK_MODE_ARG='{"value":true}' || DARK_MODE_ARG='{"value":false}'
  curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL \
    -XPOST "$DASHB_URL/api/$DASHBOARDS_URI_PATH/settings/theme:darkMode" \
    -H "$XSRF_HEADER:true" -H 'Content-type:application/json' -d "$DARK_MODE_ARG" || true

  # set default query time range
  curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL \
    -XPOST "$DASHB_URL/api/$DASHBOARDS_URI_PATH/settings" \
    -H "$XSRF_HEADER:true" -H 'Content-type:application/json' \
    -d '{"changes":{"timepicker:timeDefaults":"{\n  \"from\": \"now-24h\",\n  \"to\": \"now\",\n  \"mode\": \"quick\"}"}}' || true

  # turn off telemetry
  curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL \
    -XPOST "$DASHB_URL/api/telemetry/v2/optIn" \
    -H "$XSRF_HEADER:true" -H 'Content-type:application/json' \
    -d '{"enabled":false}' || true

  # pin filters by default
  curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL \
    -XPOST "$DASHB_URL/api/$DASHBOARDS_URI_PATH/settings/filters:pinnedByDefault" \
      -H "$XSRF_HEADER:true" -H 'Content-type:application/json' \
      -d '{"value":true}' || true

  # enable in-session storage
  curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL \
    -XPOST "$DASHB_URL/api/$DASHBOARDS_URI_PATH/settings/state:storeInSessionStorage" \
    -H "$XSRF_HEADER:true" -H 'Content-type:application/json' \
    -d '{"value":true}' || true

  echo "UI settings updates complete!"

  # end OpenSearch Tweaks
  #############################################################################################################################

  # OpenSearch Create Initial Indices

  curl "${CURL_CONFIG_PARAMS[@]}" -w "\n" -fsSL \
    -XPUT "$OPENSEARCH_URL_TO_USE/${INDEX_PATTERN%?}initial" \
    -H "$XSRF_HEADER:true" -H 'Content-type:application/json'

  touch "${STARTUP_IMPORT_PERFORMED_FILE}"

  index-refresh.py -i "$INDEX_PATTERN" -t "$TEMPLATE_NAME" --unassigned

fi # dashboards is running

echo "Success" >&2

# example command to insert some data:
#
# curl -k --config /var/local/curlrc/.creds.curlrc -sSL -XPOST -H 'Content-Type: application/json' \
#   "https://opensearch-node1:9200/ecs-$(date -u +'%Y%m%d')/_doc" -d"
# {
#  \"dns.answers.type\": \"CNAME\",
#  \"dns.question.name\": \"www.example.com\",
#  \"dns.question.registered_domain\": \"www.example.com\",
#  \"event.action\": \"CNAME\",
#  \"event.result\": \"Success\",
#  \"@timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%S.%3NZ')\"
# }"