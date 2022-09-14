FROM netboxcommunity/netbox:latest

ARG BASE_PATH=assets
ENV BASE_PATH $BASE_PATH

ADD netbox/unit/ /etc/unit/

RUN if [ "${BASE_PATH}" != "netbox" ]; then \
        mkdir /opt/netbox/$BASE_PATH && \
        mv /opt/netbox/netbox/static /opt/netbox/$BASE_PATH/static; \
    fi
