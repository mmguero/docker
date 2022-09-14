FROM netboxcommunity/netbox:latest

ARG BASE_PATH=assets
ENV BASE_PATH $BASE_PATH

ADD netbox/unit/ /etc/unit/

RUN if [ ! -d /"${BASE_PATH}" ]; then \
        mkdir /"$BASE_PATH" && \
        mv /opt/netbox/netbox/static /"$BASE_PATH"/static; \
    fi
