FROM docker.ida.lab:5000/x2go-edb

COPY pCloud_Linux*.deb /tmp/

RUN sudo apt-get update && \
    (sudo dpkg -i /tmp/pCloud_Linux*.deb ; sudo apt-get -f --no-install-recommends -y install ; sudo dpkg -i /tmp/pCloud_Linux*.deb)
