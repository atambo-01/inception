ARG ALPINE_VERSION=3.22
FROM alpine:${ALPINE_VERSION}
RUN apk update && apk upgrade && apk add --no-cache \
    mariadb \
    mariadb-client \
    gettext

RUN mkdir -p /run/mariadb /var/lib/mysql && \
    chown -R mysql:mysql /run/mariadb /var/lib/mysql

COPY conf/mariadb-server.cnf.template /etc/mariadb/templates/mariadb-server.cnf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE ${DB_PORT}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mariadbd", "--user=mysql", "--socket=/run/mariadb/mariadb.sock"]