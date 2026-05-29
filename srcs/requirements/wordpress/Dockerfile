ARG ALPINE_VERSION=3.22
FROM alpine:${ALPINE_VERSION}

# Install dependencies
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
    mariadb-client && \
    ln -sf /usr/bin/php83 /usr/bin/php && \
    mkdir -p /etc/php83/conf.d && \
    echo "memory_limit=256M" > /etc/php83/conf.d/memory-limit.ini

# Download and install WP-CLI (essential for automated setup)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Configure PHP-FPM for container networking and non-root execution
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf && \
    sed -i 's|;error_log = log/php83/error.log|error_log = /proc/self/fd/2|g' /etc/php83/php-fpm.conf

# Set up the working directory for WordPress
WORKDIR /var/www/wordpress

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Port 9000 is the standard for PHP-FPM
EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start php-fpm in the foreground (-F)
CMD ["php-fpm83", "-F"]
