#!/bin/sh

set -e
set -x

# Base apt configuration.
echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90assumeyes

# Install base tools.
apt-get update
apt-get install curl gnupg netcat-openbsd

# Install internal repository.
curl http://yum-1.centreon.com/standard/3.4/el7/stable/RPM-GPG-KEY-CES | apt-key add -
echo 'deb http://srvi-repo.int.centreon.com/apt/internal/3.5 stretch main' > /etc/apt/sources.list.d/centreon-internal.list

# Install Node.js repository.
curl -sL https://deb.nodesource.com/setup_8.x | bash -

# Install dependencies.
apt-get update
xargs apt-get install < /tmp/dependencies.txt

# Configuration.
echo 'date.timezone = Europe/Paris' > /etc/php/7.0/apache2/conf.d/50-centreon.ini
echo 'date.timezone = Europe/Paris' > /etc/php/7.0/cli/conf.d/50-centreon.ini
