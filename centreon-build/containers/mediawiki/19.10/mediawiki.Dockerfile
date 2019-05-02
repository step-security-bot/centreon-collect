# Base information.
FROM mediawiki:latest
LABEL maintainer="Matthieu Kermagoret <mkermagoret@centreon.com>"

RUN mkdir -p -m 755 /var/www/data/locks
COPY mediawiki/19.10/my_wiki.sqlite /var/www/data/
COPY mediawiki/19.10/wikicache.sqlite /var/www/data/
RUN chown -R www-data:www-data /var/www/data
COPY mediawiki/19.10/LocalSettings.php /var/www/html/
COPY mediawiki/19.10/php.ini /usr/local/etc/php/conf.d/centreon.ini
