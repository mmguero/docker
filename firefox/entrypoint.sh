#!/usr/bin/env bash

if [[ -n $PULSE_SERVER ]]; then
    cat <<EOF > /etc/pulse/client.conf
# Connect to the host's server using the mounted UNIX socket
default-server = $PULSE_SERVER

# Prevent a server running in the container
autospawn = no
daemon-binary = /bin/true

# Prevent the use of shared memory
enable-shm = false
EOF
fi

exec /opt/firefox/firefox "$@"
