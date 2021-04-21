#!/bin/sh

set -e
set -x

# Project.
PROJECT=centreon-mbi

# Check arguments.
if [ -z "$VERSION" -o -z "$RELEASE" ] ; then
  echo "You need to specify VERSION and RELEASE environment variables."
  exit 1
fi
if [ "$#" -lt 1 ] ; then
  echo "USAGE: $0 <centos7|centos8|...>"
  exit 1
fi
DISTRIB="$1"

# Pull base image.
DEP_IMAGE=registry.centreon.com/mon-dependencies-21.10:$DISTRIB
WEB_IMAGE=registry.centreon.com/mon-web-21.10:$DISTRIB
docker pull $DEP_IMAGE
docker pull $WEB_IMAGE

# Prepare Dockerfiles.
rm -rf centreon-build-containers
cp -r `dirname $0`/../../../containers centreon-build-containers
cd centreon-build-containers
sed "s/@DISTRIB@/$DISTRIB/g" < "mbi/21.10/server.Dockerfile.$DISTRIB.in" > mbi/server.Dockerfile
sed "s/@DISTRIB@/$DISTRIB/g" < "mbi/21.10/web.Dockerfile.$DISTRIB.in" > mbi/web.Dockerfile
if [ "$DISTRIB" = 'centos7' ] ; then
  sed "s#@PROJECT@#$PROJECT#g;s#@SUBDIR@#21.10/el7/noarch/mbi/$PROJECT-$VERSION-$RELEASE#g" < repo/centreon-internal.repo.in > repo/centreon-internal.repo
else
  sed "s#@PROJECT@#$PROJECT#g;s#@SUBDIR@#21.10/el8/noarch/mbi/$PROJECT-$VERSION-$RELEASE#g" < repo/centreon-internal.repo.in > repo/centreon-internal.repo
fi

# Build image.
REGISTRY="registry.centreon.com"
MBI_SERVER_IMAGE="$REGISTRY/des-mbi-server-$VERSION-$RELEASE:$DISTRIB"
MBI_SERVER_WIP_IMAGE="$REGISTRY/des-mbi-server-21.10-wip:$DISTRIB"
MBI_WEB_IMAGE="$REGISTRY/des-mbi-web-$VERSION-$RELEASE:$DISTRIB"
MBI_WEB_WIP_IMAGE="$REGISTRY/des-mbi-web-21.10-wip:$DISTRIB"
docker build --no-cache -t "$MBI_SERVER_IMAGE" -f mbi/server.Dockerfile .
docker build --no-cache -t "$MBI_WEB_IMAGE" -f mbi/web.Dockerfile .
docker tag "$MBI_SERVER_IMAGE" "$MBI_SERVER_WIP_IMAGE"
docker tag "$MBI_WEB_IMAGE" "$MBI_WEB_WIP_IMAGE"
docker push "$MBI_SERVER_IMAGE"
docker push "$MBI_SERVER_WIP_IMAGE"
docker push "$MBI_WEB_IMAGE"
docker push "$MBI_WEB_WIP_IMAGE"
