#!/bin/sh

set -e
set -x

. `dirname $0`/../../common.sh

# Project.
PROJECT=centreon-bam-server

# Check arguments.
if [ -z "$VERSION" -o -z "$RELEASE" ] ; then
  echo "You need to specify VERSION and RELEASE environment variables."
  exit 1
fi
if [ "$#" -lt 1 ] ; then
  echo "USAGE: $0 <centos6|centos7|...>"
  exit 1
fi
DISTRIB="$1"

# Pull images.
REGISTRY="ci.int.centreon.com:5000"
BAM_IMAGE="$REGISTRY/des-bam-$VERSION-$RELEASE:$DISTRIB"
docker pull $BAM_IMAGE

# Get sources.
rm -rf "$PROJECT-$VERSION-full" "$PROJECT-$VERSION-full.tar.gz"
get_internal_source "bam/$PROJECT-$VERSION-$RELEASE/$PROJECT-$VERSION-full.tar.gz"
tar xzf "$PROJECT-$VERSION-full.tar.gz"

# Prepare Docker Compose file.
sed 's#@WEB_IMAGE@#'$BAM_IMAGE'#g' < `dirname $0`/../../../containers/web/3.4/docker-compose.yml.in > "$PROJECT-$VERSION-full/docker-compose-bam.yml"

# Copy compose file of webdriver
cp `dirname $0`/../../../containers/webdrivers/docker-compose.yml.in "$PROJECT-$VERSION-full/docker-compose-webdriver.yml"

# Prepare Behat.yml
cd "$PROJECT-$VERSION-full"
alreadyset=`grep docker-compose-bam.yml < behat.yml || true`
if [ -z "$alreadyset" ] ; then
  sed -i 's#    Centreon\\Test\\Behat\\Extensions\\ContainerExtension:#    Centreon\\Test\\Behat\\Extensions\\ContainerExtension:\n      log_directory: ../acceptance-logs\n      bam: docker-compose-bam.yml#g' behat.yml
fi

# Run acceptance tests.
rm -rf ../xunit-reports
mkdir ../xunit-reports
rm -rf ../acceptance-logs
mkdir ../acceptance-logs
composer install
launch_webdriver docker-compose-webdriver.yml
ls features/*.feature | parallel ./vendor/bin/behat --format=pretty --out=std --format=junit --out="../xunit-reports/{/.}" "{}" || true
stop_webdriver docker-compose-webdriver.yml
