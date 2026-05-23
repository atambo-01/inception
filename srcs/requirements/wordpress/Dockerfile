FROM alpine:3.19

# Install dependencies
RUN apk update && apk upgrade && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-phar \
    php83-mbstring \
    php83-openssl \
    php83-curl \
    php83-json \
    php83-dom \
    php83-xml \
    php83-zip \
    wget \
    mariadb-client && \
    ln -s /usr/bin/php83 /usr/bin/php && \
    echo "memory_limit=256M" > /etc/php83/conf.d/memory-limit.ini

# Download and install WP-CLI (essential for automated setup)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Configure PHP-FPM to listen on port 9000 instead of local socket
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php83/php-fpm.d/www.conf

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
