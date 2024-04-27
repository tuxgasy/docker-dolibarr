# Dolibarr on Docker

Docker image for Dolibarr with auto installer on first boot.

## Supported tags

* 15.0.3-php7.4 15.0.3 15
* 16.0.5-php8.1 16.0.5 16
* 17.0.4-php8.1 17.0.4 17
* 18.0.5-php8.1 18.0.5 18
* 19.0.1-php8.2 19.0.1 19 latest
* develop

**End of support for PHP < 7.4**

**Dolibarr versions 7, 8, 9, 10, 11, 12, 13, 14 no more updated**

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

| Variable                        | Default value                  | Description |
| ------------------------------- | ------------------------------ | ----------- |
| **DOLI_INSTALL_AUTO**           | *1*                            | 1: The installation will be executed on first boot
| **DOLI_PROD**                   | *1*                            | 1: Dolibarr will be run in production mode
| **DOLI_DB_TYPE**                | *mysqli*                       | Type of the DB server (**mysqli**, pgsql)
| **DOLI_DB_HOST**                | *mysql*                        | Host name of the MariaDB/MySQL server
| **DOLI_DB_HOST_PORT**           | *3306*                         | Host port of the MariaDB/MySQL server
| **DOLI_DB_USER**                | *doli*                         | Database user
| **DOLI_DB_PASSWORD**            | *doli_pass*                    | Database user's password
| **DOLI_DB_NAME**                | *dolidb*                       | Database name
| **DOLI_ADMIN_LOGIN**            | *admin*                        | Admin's login create on the first boot
| **DOLI_ADMIN_PASSWORD**         | *admin*                        | Admin'password
| **DOLI_URL_ROOT**               | *http://localhost*             | Url root of the Dolibarr installation
| **DOLI_ENABLE_MODULES**         |                                | Comma-separated list of modules to be activated at install. modUser will always be activated. (Ex: `Societe,Facture,Stock`)
| **DOLI_COMPANY_NAME**           |                                | Set the company name of Dolibarr at container init
| **DOLI_COMPANY_COUNTRYCODE**    |                                | Set the company and Dolibarr country at container init. Need 2-letter codes like "FR", "GB", "US",...
| **PHP_INI_DATE_TIMEZONE**       | *UTC*                          | Default timezone on PHP
| **PHP_INI_MEMORY_LIMIT**        | *256M*                         | PHP Memory limit
| **PHP_INI_UPLOAD_MAX_FILESIZE** | *2M*                           | PHP Maximum allowed size for uploaded files
| **PHP_INI_POST_MAX_SIZE**       | *8M*                           | PHP Maximum size of POST data that PHP will accept.
| **PHP_INI_ALLOW_URL_FOPEN**     | *0*                            | Allow URL-aware fopen wrappers
| **WWW_USER_ID**                 |                                | ID of user www-data. ID will not changed if leave empty. During a development, it is very practical to put the same ID as the host user.
| **WWW_GROUP_ID**                |                                | ID of group www-data. ID will not changed if leave empty.
| **DOLI_AUTH**                   | *dolibarr*                     | Which method is used to connect users, change to `ldap` or `ldap, dolibarr` to use LDAP
| **DOLI_LDAP_HOST**              | *127.0.0.1*                    | The host of the LDAP server
| **DOLI_LDAP_PORT**              | *389*                          | The port of the LDAP server
| **DOLI_LDAP_VERSION**           | *3*                            | The version of LDAP to use
| **DOLI_LDAP_SERVER_TYPE**       | *openldap*                     | The type of LDAP server (openLDAP, Active Directory, eGroupWare)
| **DOLI_LDAP_LOGIN_ATTRIBUTE**   | *uid*                          | The attribute used to bind users
| **DOLI_LDAP_DN**                | *ou=users,dc=my-domain,dc=com* | The base where to look for users
| **DOLI_LDAP_FILTER**            |                                | The filter to authorise users to connect
| **DOLI_LDAP_BIND_DN**           |                                | The complete DN of the user with read access on users
| **DOLI_LDAP_BIND_PASS**         |                                | The password of the bind user
| **DOLI_LDAP_DEBUG**             | *false*                        | Activate debug mode
| **DOLI_CRON**                   | *0*                            | 1: Enable cron service
| **DOLI_CRON_KEY**               |                                | Security key launch cron jobs
| **DOLI_CRON_USER**              |                                | Dolibarr user used for cron jobs
| **DOLI_INSTANCE_UNIQUE_ID**     |                                | Secret ID used as a salt / key for some encryption. By default, it is set randomly when the docker container is created.

Some environment variables are compatible with docker secrets behaviour, just add the `_FILE` suffix to var name and point the value file to read.
Environment variables that are compatible with docker secrets:

* `DOLI_DB_USER` => `DOLI_DB_USER_FILE`
* `DOLI_DB_PASSWORD` => `DOLI_DB_PASSWORD_FILE`
* `DOLI_ADMIN_LOGIN` => `DOLI_ADMIN_LOGIN_FILE`
* `DOLI_ADMIN_PASSWORD` => `DOLI_ADMIN_PASSWORD_FILE`
* `DOLI_CRON_KEY` => `DOLI_CRON_KEY_FILE`
* `DOLI_CRON_USER` => `DOLI_CRON_USER_FILE`
* `DOLI_INSTANCE_UNIQUE_ID` => `DOLI_INSTANCE_UNIQUE_ID_FILE`

## Add post-deployment scripts
It is possible to execute `*.sql` and `*.php` custom file at the end of deployment by mounting a volume with the following structure : 
```
\volume
|-\sql
| |- custom_script.sql
|
|-\php
| |- custom_script.php
```

Mount the volume with compose file : 
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
        volumes :
          - volume-scripts:/var/www/scripts/docker-init
        ports:
            - "80:80"
        links:
            - mariadb
```

or more specifically 
```
        volumes : 
          - volume-scripts-sql:/var/www/scripts/docker-init/sql
          - volume-scripts-php:/var/www/scripts/docker-init/php
```
