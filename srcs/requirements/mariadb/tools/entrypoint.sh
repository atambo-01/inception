#!/bin/sh
set -eu

# Read secrets from files if provided
if [ -n "$MARIADB_ROOT_PASSWORD_FILE" ] && [ -f "$MARIADB_ROOT_PASSWORD_FILE" ]; then
    export MARIADB_ROOT_PASSWORD=$(cat "$MARIADB_ROOT_PASSWORD_FILE")
fi

if [ -n "$MARIADB_PASSWORD_FILE" ] && [ -f "$MARIADB_PASSWORD_FILE" ]; then
    export MARIADB_PASSWORD=$(cat "$MARIADB_PASSWORD_FILE")
fi

# Now check required variables using MARIADB_* names
if [ -z "${MARIADB_ROOT_PASSWORD:-}" ] || [ -z "${MARIADB_DATABASE:-}" ] || \
   [ -z "${MARIADB_USER:-}" ] || [ -z "${MARIADB_PASSWORD:-}" ]; then
        echo "Missing required MariaDB environment variables" >&2
        echo "Need MARIADB_ROOT_PASSWORD, MARIADB_DATABASE, MARIADB_USER, MARIADB_PASSWORD" >&2
        exit 1
fi

# Map to MYSQL_* for the bootstrap commands
MYSQL_ROOT_PASSWORD="$MARIADB_ROOT_PASSWORD"
MYSQL_DATABASE="$MARIADB_DATABASE"
MYSQL_USER="$MARIADB_USER"
MYSQL_PASSWORD="$MARIADB_PASSWORD"

mkdir -p /run/mariadb /var/lib/mysql
chown -R mysql:mysql /run/mariadb /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null

envsubst '${DB_PORT}' < /etc/mariadb/templates/mariadb-server.cnf.template > /etc/my.cnf.d/mariadb-server.cnf


mariadbd --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

fi

exec "$@"
