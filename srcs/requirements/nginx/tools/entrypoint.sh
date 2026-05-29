#!/bin/sh
set -e

mkdir -p /etc/nginx/ssl
mkdir -p /etc/nginx/http.d

if [ ! -f "/etc/nginx/ssl/nginx.crt" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME}"
fi

envsubst '${NGINX_PORT} ${DOMAIN_NAME}' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/http.d/default.conf

exec nginx -g 'daemon off;'


