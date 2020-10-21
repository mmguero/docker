#!/usr/bin/env bash

set -e

if [ -n "$CROC_PORT_LOW" ] && [ -n "$CROC_PORT_HIGH" ]; then
  PORTS="$(seq -s , "$CROC_PORT_LOW" "$CROC_PORT_HIGH")"
else
  PORTS="$(seq -s , 9009 9013)"
fi

if [ -n "$CROC_PASS" ]; then
  /usr/local/bin/croc --pass "$CROC_PASS" relay --ports "$PORTS"
else
  /usr/local/bin/croc relay --ports "$PORTS"
fi
