ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}

RUN apk update && apk upgrade && apk add --no-cache \
    nginx \
    openssl

RUN mkdir -p /run/nginx /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=atambo.42.fr"

COPY conf/nginx.conf /etc/nginx/http.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
