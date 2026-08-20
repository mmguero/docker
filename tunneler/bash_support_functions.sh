function server()
{
    local PORT="${1:-8000}"
    command -v xdg-open >/dev/null 2>&1 && sleep 1 && xdg-open "http://localhost:${PORT}/" &
    if command -v goStatic >/dev/null 2>&1; then
        goStatic -vhost "" -path "$(pwd)" -port $PORT
    elif command -v python3 >/dev/null 2>&1; then
        python3 -m http.server --bind 0.0.0.0 $PORT
    elif command -v python >/dev/null 2>&1; then
        python -m SimpleHTTPServer $PORT
    elif command -v ruby >/dev/null 2>&1; then
        ruby -run -e httpd -- --bind-address=0.0.0.0 --port=$PORT .
    elif command -v http-server >/dev/null 2>&1; then
        http-server -a 0.0.0.0 --port $PORT
    elif command -v php >/dev/null 2>&1; then
        php -S 0.0.0.0:$PORT -t .
    else
        echo "No tool available for service HTTP" >&2
    fi
}

function hys()
{
  hostyoself host --url "${HOSTYOSELF_URL:-https://hostyoself.com}"
}

function hysi_cleanup()
{
  local DEL_IDX="${1}"
  local HYS_PID="${2}"
  [[ -n "${DEL_IDX}" ]] && [[ -f "${DEL_IDX}" ]] && rm -vf "${DEL_IDX}"
  [[ -n "${HYS_PID}" ]] && kill ${HYS_PID} 2>/dev/null
}

function _hysi()
{
  local DEL_IDX=
  local HYS_PID=
  if [[ ! -f ./index.html ]] && command -v tree >/dev/null 2>&1 && tree -x --dirsfirst -H . -o index.html >/dev/null 2>&1; then
    DEL_IDX=./index.html
  fi
  hostyoself host --url "${HOSTYOSELF_URL:-https://hostyoself.com}" &
  HYS_PID=$!
  trap "hysi_cleanup '${DEL_IDX}' ${HYS_PID}" SIGINT EXIT RETURN
  while [[ -n "$(ps -p ${HYS_PID} -o pid=)" ]]; do
    sleep 5 &
    wait $!
    [[ -n "${DEL_IDX}" ]] && \
      [[ -f "${DEL_IDX}" ]] && \
      (( ($(date +%s) - $(date +%s -r "${DEL_IDX}" 2>/dev/null || date +%s)) >= 60 )) && \
      tree -x --dirsfirst -H . -o "${DEL_IDX}" >/dev/null 2>&1
  done
}

function hysi()
{
  _hysi 2>/dev/null
}

alias crocs='croc --yes'