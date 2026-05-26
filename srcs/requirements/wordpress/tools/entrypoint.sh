#!/bin/sh
set -eu

# Read secrets if _FILE variables are set
if [ -n "${WORDPRESS_DB_PASSWORD_FILE:-}" ] && [ -f "$WORDPRESS_DB_PASSWORD_FILE" ]; then
    export MYSQL_PASSWORD=$(cat "$WORDPRESS_DB_PASSWORD_FILE")
fi
if [ -n "${WP_ADMIN_PASSWORD_FILE:-}" ] && [ -f "$WP_ADMIN_PASSWORD_FILE" ]; then
    export WP_ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD_FILE")
fi
if [ -n "${WP_USER_PASSWORD_FILE:-}" ] && [ -f "$WP_USER_PASSWORD_FILE" ]; then
    export WP_USER_PASSWORD=$(cat "$WP_USER_PASSWORD_FILE")
fi

# Wait for MariaDB to be ready
# We use mariadb-client to check the connection
count=0
until mysqladmin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    count=$((count+1))
    if [ $count -gt 5 ]; then
        echo "Error: Could not connect to MariaDB after 5 attempts."
        exit 1
    fi
    echo "Waiting for MariaDB... (attempt $count/5)"
    sleep 2
done

if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root --force   # --force overwrites existing files

    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="atambo inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    echo "Creating second user..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
else
    echo "WordPress already configured. Skipping setup."
fi

echo "WordPress is ready."
exec "$@"
