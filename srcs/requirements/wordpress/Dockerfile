ARG ALPINE_VERSION=3.22
FROM alpine:${ALPINE_VERSION}

# Install dependencies (including gettext for envsubst)
RUN apk update && apk upgrade && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-phar \
    php83-mbstring \
    php83-openssl \
    php83-curl \
    php83-dom \
    php83-xml \
    php83-zip \
    wget \
    mariadb-client \
    gettext && \
    ln -sf /usr/bin/php83 /usr/bin/php && \
    mkdir -p /etc/php83/conf.d && \
    echo "memory_limit=256M" > /etc/php83/conf.d/memory-limit.ini

# Download and install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Remove the default PHP-FPM config (we'll generate it at runtime)
RUN rm -f /etc/php83/php-fpm.d/www.conf

# Copy the template (without listen.allowed_clients)
COPY conf/www.conf.template /etc/php83/php-fpm.d/www.conf.template

WORKDIR /var/www/wordpress

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm83", "-F"]