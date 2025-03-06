#!/bin/bash

docker run -d --restart=always --name registry -v "$(pwd)"/certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key -p 5000:5000 registry:2
