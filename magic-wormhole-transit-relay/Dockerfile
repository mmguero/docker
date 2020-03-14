FROM debian:testing-slim

RUN export user=wormhole \
  && groupadd -r $user && useradd -r -g $user $user

RUN apt-get update \
  && apt-get install --no-install-recommends -qy \
    python3-pip \
    python3-twisted \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install magic-wormhole-transit-relay

EXPOSE 4001
CMD [ "twist3", "transitrelay", "--port=tcp:4001", "--blur-usage=100" ]
