#!/usr/bin/env bash

if [[ -e /dev/snd ]]; then
	exec /usr/bin/apulse /opt/firefox/firefox "$@"
else
	exec /opt/firefox/firefox "$@"
fi
