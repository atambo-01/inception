ARG ALPINE_VERSION=3.22
FROM alpine:${ALPINE_VERSION}

RUN apk update && apk upgrade && apk add --no-cache \
    nginx \
    openssl \
    gettext

RUN mkdir -p /run/nginx /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=${DOMAIN_NAME}"

COPY conf/nginx.conf.template /etc/nginx/templates/nginx.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]