FROM netboxcommunity/netbox:latest

ARG BASE_PATH=assets
ENV BASE_PATH $BASE_PATH

RUN if [ -n "${BASE_PATH}" ] && [ "${BASE_PATH}" != "netbox" ]; then \
        mkdir /opt/netbox/netbox/$BASE_PATH && \
        mv /opt/netbox/netbox/static /opt/netbox/netbox/$BASE_PATH/static; \
    fi
