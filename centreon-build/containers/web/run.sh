#!/bin/sh

#set -e
set -x

service mysql start
while true ; do
  retval=`mysql centreon -e 'SELECT * FROM nagios_server' > /dev/null ; echo $?`
  if [ "$retval" = 0 ] ; then
    break ;
  else
    echo 'DB server is not yet available.'
    sleep 1
  fi
done
/etc/init.d/cbd start
/etc/init.d/centengine start
su - centreon -c centcore &
httpd -k start
tailf /var/log/httpd/error_log
