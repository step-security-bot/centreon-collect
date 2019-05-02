FROM registry.centreon.com/mon-web-fresh-19.10:centos7
MAINTAINER Matthieu Kermagoret <mkermagoret@centreon.com>

# Centreon update is made through custom scripts.
# COPY centreon-build/container.cnf /etc/my.cnf.d/
# COPY centreon-build /tmp/dev
# RUN chmod +x /tmp/dev/dev.sh && \
#     chmod 0644 /etc/my.cnf.d/container.cnf
COPY composer.json /usr/share/centreon/composer.json
COPY package.json /usr/share/centreon/package.json
COPY www/front_src/webpack.config.js /usr/share/centreon/www/front_src/webpack.config.js
COPY bootstrap.php /usr/share/centreon/bootstrap.php
COPY vendor /usr/share/centreon/vendor
COPY node_modules /usr/share/centreon/node_modules
COPY GPL_LIB /usr/share/centreon/GPL_LIB
RUN chown apache:apache /usr/share/centreon/GPL_LIB/SmartyCache/compile
COPY bin /usr/share/centreon/bin
RUN chmod +x /usr/share/centreon/bin/*
COPY src /usr/share/centreon/src
COPY www/class /usr/share/centreon/www/class
# COPY www/install /usr/share/centreon/www/install
COPY tmpl/install/sudoersCentreonEngine /etc/sudoers.d/centreon
RUN sed -i 's/@CENTREON_GROUP@/centreon/g' /etc/sudoers.d/centreon
# RUN /tmp/dev/dev.sh

# Static sources.
COPY tmpl/install/centreon.cron /etc/cron.d/centreon
COPY tmpl/install/centstorage.cron /etc/cron.d/centstorage
COPY cron /usr/share/centreon/cron
RUN chmod a+x /usr/share/centreon/cron/* && sed -i 's#@CENTREON_ETC@#/etc/centreon#g' /usr/share/centreon/cron/*
COPY www/sounds /usr/share/centreon/www/sounds
COPY www/img /usr/share/centreon/www/img
COPY www/widgets /usr/share/centreon/www/widgets
COPY www/modules /usr/share/centreon/www/modules
COPY lib /usr/share/centreon/lib
COPY www/index.php /usr/share/centreon/www/index.php
COPY www/main.php /usr/share/centreon/www/main.php
COPY www/Themes /usr/share/centreon/www/Themes
COPY www/lib /usr/share/centreon/www/lib
COPY www/include /usr/share/centreon/www/include
COPY www/api /usr/share/centreon/www/api
COPY www/class /usr/share/centreon/www/class
