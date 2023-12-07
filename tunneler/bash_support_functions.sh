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
  hostyoself host --url ${HOSTYOSELF_URL:-https://hostyoself.com}
}

function hysi_cleanup()
{
  local DEL_IDX="${1}"
  [[ -n "$DEL_IDX" ]] && [[ -f "$DEL_IDX" ]] && rm -vf "$DEL_IDX"
}

function hysi()
{
  local DEL_IDX=
  if [[ ! -f ./index.html ]] && command -v tree >/dev/null 2>&1 && tree -x --dirsfirst --gitignore -H . -o index.html >/dev/null 2>&1; then
    DEL_IDX=./index.html
  fi
  trap "hysi_cleanup '${DEL_IDX}'" SIGINT EXIT RETURN
  hys
}

alias crocs='croc --yes'