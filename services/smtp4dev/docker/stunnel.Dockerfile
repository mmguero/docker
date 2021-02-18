FROM vimagick/stunnel:latest

RUN sed -i '/cert =.*/i CAfile = /etc/stunnel/ca.crt' /entrypoint.sh
