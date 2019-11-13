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
  echo "USAGE: $0 <centos7|...>"
  exit 1
fi
DISTRIB="$1"

# Fetch sources.
rm -rf "$PROJECT-$VERSION.tar.gz" "$PROJECT-$VERSION"
get_internal_source "bam/$PROJECT-$VERSION-$RELEASE/$PROJECT-$VERSION-full.tar.gz"
tar xzf "$PROJECT-$VERSION-full.tar.gz"

# Launch mon-unittest container.
UT_IMAGE=registry.centreon.com/mon-unittest-20.04:$DISTRIB
docker pull $UT_IMAGE
containerid=`docker create $UT_IMAGE /usr/local/bin/unittest.sh $PROJECT`

# Copy sources to container.
docker cp `dirname $0`/des-bam-unittest.container.sh "$containerid:/usr/local/bin/unittest.sh"
docker cp "$PROJECT-$VERSION-full" "$containerid:/usr/local/src/$PROJECT"

# Run unit tests.
docker start -a "$containerid"
docker cp "$containerid:/tmp/ut-be.xml" ut-be.xml
docker cp "$containerid:/tmp/ut-fe.xml" ut-fe.xml
docker cp "$containerid:/tmp/coverage-be.xml" coverage-be.xml
docker cp "$containerid:/tmp/codestyle-be.xml" codestyle-be.xml
docker cp "$containerid:/tmp/codestyle-fe.xml" codestyle-fe.xml

# Stop container.
docker stop "$containerid"
docker rm "$containerid"
