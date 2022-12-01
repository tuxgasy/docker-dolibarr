# Dolibarr on Docker

Docker image for Dolibarr with auto installer on first boot.

## Supported tags

* 11.0.5-php7.4 11.0.5 11
* 12.0.5-php7.4 12.0.5 12
* 13.0.4-php7.4 13.0.4 13
* 14.0.5-php7.4 14.0.5 14
* 15.0.3-php7.4 15.0.3 15
* 16.0.3-php8.1 16.0.3 16 latest
* develop

**End of support for PHP < 7.4**

**Dolibarr versions 7, 8, 9, 10 no more updated**

## Supported architectures

Linux x86-64 (`amd64`), ARMv7 32-bit (`arm32v7` :warning: MariaDB/Mysql docker images don't support it) and ARMv8 64-bit (`arm64v8`)

## What is Dolibarr ?

Dolibarr ERP & CRM is a modern software package to manage your organization's activity (contacts, suppliers, invoices, orders, stocks, agenda, ...).

> [More information](https://github.com/dolibarr/dolibarr)

## How to run this image ?

This image is based on the [official PHP repository](https://registry.hub.docker.com/_/php/).

**Important**: This image don't contains database. So you need to link it with a database container.

Let's use [Docker Compose](https://docs.docker.com/compose/) to integrate it with [MariaDB](https://hub.docker.com/_/mariadb/) (you can also use [MySQL](https://hub.docker.com/_/mysql/) if you prefer).

Create `docker-compose.yml` file as following:

```yaml
version: "3"

services:
    mariadb:
        image: mariadb:latest
        environment:
            MYSQL_ROOT_PASSWORD: root
            MYSQL_DATABASE: dolibarr

    web:
        image: tuxgasy/dolibarr
        environment:
            DOLI_DB_HOST: mariadb
            DOLI_DB_USER: root
            DOLI_DB_PASSWORD: root
            DOLI_DB_NAME: dolibarr
            DOLI_URL_ROOT: 'http://0.0.0.0'
            PHP_INI_DATE_TIMEZONE: 'Europe/Paris'
        ports:
            - "80:80"
        links:
            - mariadb
```

Then run all services `docker-compose up -d`. Now, go to http://0.0.0.0 to access to the new Dolibarr installation.

### Other examples

You can find several examples in the `examples` directory, such as:
 - [Running Dolibarr with a mysql server](./examples/with-mysql/dolibarr-with-mysql.md)
 - [Running Dolibarr with a Traefik reverse proxy](./examples/with-rp-traefik/dolibarr-with-traefik.md)
 - [Running Dolibarr with secrets](./examples/with-secrets/dolibarr-with-secrets.md)

## Upgrading version and migrating DB
The `install.lock` file is located inside the container volume `/var/www/documents`.

Remove the `install.lock` file and start an updated version container. Ensure that env `DOLI_INSTALL_AUTO` is set to `1`. It will migrate Database to the new version.
You can still use the standard way to upgrade through web interface.

## Early support for PostgreSQL
Setting `DOLI_DB_TYPE` to `pgsql` enable Dolibarr to run with a PostgreSQL database.
When set to use `pgsql`, Dolibarr must be installed manually on it's first execution:
 - Browse to `http://0.0.0.0/install`;
 - Follow the installation setup;
 - Add `install.lock` inside the container volume `/var/www/html/documents` (ex `docker-compose exec services-data_dolibarr_1 /bin/bash -c "touch /var/www/html/documents/install.lock"`).

When setup this way, to upgrade version the use of the web interface is mandatory:
 - Remove the `install.lock` file (ex `docker-compose exec services-data_dolibarr_1 /bin/bash -c "rm -f /var/www/html/documents/install.lock"`).
 - Browse to `http://0.0.0.0/install`;
 - Upgrade DB;
 - Add `install.lock` inside the container volume `/var/www/html/documents` (ex `docker-compose exec services-data_dolibarr_1 /bin/bash -c "touch /var/www/html/documents/install.lock"`).

## Environment variables summary

| Variable                      | Default value                  | Description |
| ----------------------------- | ------------------------------ | ----------- |
| **DOLI_INSTALL_AUTO**         | *1*                            | 1: The installation will be executed on first boot
| **DOLI_DB_TYPE**              | *mysqli*                       | Type of the DB server (**mysqli**, pgsql)
| **DOLI_DB_HOST**              | *mysql*                        | Host name of the MariaDB/MySQL server
| **DOLI_DB_HOST_PORT**         | *3306*                         | Host port of the MariaDB/MySQL server
| **DOLI_DB_USER**              | *doli*                         | Database user
| **DOLI_DB_PASSWORD**          | *doli_pass*                    | Database user's password
| **DOLI_DB_NAME**              | *dolidb*                       | Database name
| **DOLI_ADMIN_LOGIN**          | *admin*                        | Admin's login create on the first boot
| **DOLI_ADMIN_PASSWORD**       | *admin*                        | Admin'password
| **DOLI_URL_ROOT**             | *http://localhost*             | Url root of the Dolibarr installation
| **PHP_INI_DATE_TIMEZONE**     | *UTC*                          | Default timezone on PHP
| **PHP_INI_MEMORY_LIMIT**      | *256M*                         | PHP Memory limit
| **WWW_USER_ID**               |                                | ID of user www-data. ID will not changed if leave empty. During a development, it is very practical to put the same ID as the host user.
| **WWW_GROUP_ID**              |                                | ID of group www-data. ID will not changed if leave empty.
| **DOLI_AUTH**                 | *dolibarr*                     | Which method is used to connect users, change to `ldap` or `ldap, dolibarr` to use LDAP
| **DOLI_LDAP_HOST**            | *127.0.0.1*                    | The host of the LDAP server
| **DOLI_LDAP_PORT**            | *389*                          | The port of the LDAP server
| **DOLI_LDAP_VERSION**         | *3*                            | The version of LDAP to use
| **DOLI_LDAP_SERVER_TYPE**     | *openldap*                     | The type of LDAP server (openLDAP, Active Directory, eGroupWare)
| **DOLI_LDAP_LOGIN_ATTRIBUTE** | *uid*                          | The attribute used to bind users
| **DOLI_LDAP_DN**              | *ou=users,dc=my-domain,dc=com* | The base where to look for users
| **DOLI_LDAP_FILTER**          |                                | The filter to authorise users to connect
| **DOLI_LDAP_BIND_DN**         |                                | The complete DN of the user with read access on users
| **DOLI_LDAP_BIND_PASS**       |                                | The password of the bind user
| **DOLI_LDAP_DEBUG**           | *false*                        | Activate debug mode
| **DOLI_CRON**                 | *0*                            | 1: Enable cron service
| **DOLI_CRON_KEY**             |                                | Security key launch cron jobs
| **DOLI_CRON_USER**            |                                | Dolibarr user used for cron jobs

Some environment variables are compatible with docker secrets behaviour, just add the `_FILE` suffix to var name and point the value file to read.
Environment variables that are compatible with docker secrets:
 - `DOLI_DB_USER` => `DOLI_DB_USER_FILE`
 - `DOLI_DB_PASSWORD` => `DOLI_DB_PASSWORD_FILE`
 - `DOLI_ADMIN_LOGIN` => `DOLI_ADMIN_LOGIN_FILE`
 - `DOLI_ADMIN_PASSWORD` => `DOLI_ADMIN_PASSWORD_FILE`
