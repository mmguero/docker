FROM jlesage/baseimage-gui:alpine-3.24-v4

ENV APP_NAME "Wireshark"
ENV WEB_FILE_MANAGER 1
ENV DISABLE_GLX 1

RUN add-pkg wireshark tshark fontconfig ttf-dejavu font-noto && fc-cache -f
COPY startapp.sh /startapp.sh
