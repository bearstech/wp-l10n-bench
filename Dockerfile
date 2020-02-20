# Copyright (C) 2020 Bearstech - https://bearstech.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This is a Debian 9(stretch) based image, ready with a Symfony/Drupal/WP
# compatible PHP environment.
FROM bearstech/php:7.2

# Install MariaDB (server+client) and Apache Bench. Yes we're making a fat
# container for the purpose of a quick and simple benchmark.
RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends mariadb-server mariadb-client apache2-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --gecos wp --home /wp wp

# Download and install WP-CLI, then use it to install a french-localized WP.
# The last 'sed' tweaks the global french locale selection, in order we can
# select it from the becnhmark via the WPLANG env var :
# - WPLANG=""      : default/english locale (no translations loaded)
# - WPLANG="fr_FR" : french locale
USER wp
WORKDIR /wp
COPY wp-config.php /wp/
RUN set -eux \
    && curl -s https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar >wp \
    && chmod +x wp \
    && ./wp core download --locale=fr_FR --version=5.3.2 \
    && sed -i -e 's/^\(\$wp_local_package\).*/\1 = getenv("WPLANG") ?: NULL;/' wp-includes/version.php

# Run WP setup to populate and configure the database, obviously requires a
# running database server.
USER root
RUN set -eux \
    && mysqld_safe & sleep 2 \
    && mysql -e "CREATE DATABASE wp; GRANT ALL PRIVILEGES ON wp.* TO wp@localhost IDENTIFIED BY 'wp'" \
    && su -l -c '/wp/wp core install --url="127.0.0.1:8000" --title="WP" --admin_user=admin --admin_password=admin --admin_email=admin@wp.local' wp \
    && mysqladmin shutdown

COPY benchmark /
CMD ["/benchmark"]
