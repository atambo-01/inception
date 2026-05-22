#!/bin/sh
set -eu

if [ -z "${MYSQL_ROOT_PASSWORD:-}" ] || [ -z "${MYSQL_DATABASE:-}" ] || \
   [ -z "${MYSQL_USER:-}" ] || [ -z "${MYSQL_PASSWORD:-}" ]; then
	echo "Missing required MariaDB environment variables" >&2
	exit 1
fi

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null

	mariadbd --user=mysql --bootstrap <<-EOSQL
		FLUSH PRIVILEGES;
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
		FLUSH PRIVILEGES;
	EOSQL
fi

exec "$@"
