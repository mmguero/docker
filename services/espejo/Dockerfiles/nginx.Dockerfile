FROM nginx

ADD config/nginx.conf /etc/nginx/nginx.conf

VOLUME ["/mnt/mirror/debian"]
