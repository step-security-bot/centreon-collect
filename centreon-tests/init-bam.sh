#!/bin/bash
mysql -e "CREATE USER IF NOT EXISTS 'centreon'@'localhost' IDENTIFIED BY 'centreon';"

mysql -e "GRANT SELECT,UPDATE,DELETE,INSERT,CREATE,DROP,INDEX,ALTER,LOCK TABLES,CREATE TEMPORARY TABLES, EVENT,CREATE VIEW ON *.* TO  'centreon'@'localhost';"

mysql -u centreon -p -e "DROP DATABASE centreon_storage;"
mysql -u centreon -p -e "DROP DATABASE centreon;"
mysql -u centreon -p < ../centreon-broker/simu/docker/centreon_storage.sql
mysql -u centreon -p < ../centreon-broker/simu/docker/centreon.sql
mysql centreon -u centreon -p < ../centreon-broker/simu/docker/bam.sql
