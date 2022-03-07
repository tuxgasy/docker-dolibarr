# Dolibarr with postgres

Running a Dolibarr instance with a postgres server is a new behaviour, this examples show you how to describe this architecture in a docker-compose way.

When set to use `pgsql`, Dolibarr must be installed manually on it's first execution:
 - Browse to `http://0.0.0.0/install`;
 - Follow the installation setup;
 - Add `install.lock` inside the container volume `/var/www/html/documents` (ex `docker-compose exec services-data_dolibarr_1 /bin/bash -c "touch /var/www/html/documents/install.lock"`).
