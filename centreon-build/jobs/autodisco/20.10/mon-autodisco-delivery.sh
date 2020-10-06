#!/bin/sh

set -e
set -x

. `dirname $0`/../../common.sh

# Project.
PROJECT=centreon-autodiscovery

# Check arguments.
if [ -z "$VERSION" -o -z "$RELEASE" ] ; then
  echo "You need to specify VERSION and RELEASE environment variables."
  exit 1
fi

#
# Release delivery.
#
if [ "$BUILD" '=' 'RELEASE' ] ; then
  # Copy artifacts.
  copy_internal_source_to_testing "standard" "autodisco" "$PROJECT-$VERSION-$RELEASE"
  copy_internal_rpms_to_testing "standard" "20.10" "el7" "noarch" "autodisco" "$PROJECT-$VERSION-$RELEASE"
  copy_internal_rpms_to_testing "standard" "20.10" "el8" "noarch" "autodisco" "$PROJECT-$VERSION-$RELEASE"

  # Docker image target version.
  TARGETVERSION="$VERSION"

#
# CI delivery.
#
else
  # Move RPMs to unstable.
  promote_canary_rpms_to_unstable "standard" "20.10" "el7" "noarch" "autodisco" "$PROJECT-$VERSION-$RELEASE"
  promote_canary_rpms_to_unstable "standard" "20.10" "el8" "noarch" "autodisco" "$PROJECT-$VERSION-$RELEASE"

  # Docker image target version.
  TARGETVERSION='20.10'
fi

# Set Docker images as latest.
REGISTRY='registry.centreon.com'
for distrib in centos7 centos8 ; do
  docker pull "$REGISTRY/mon-autodisco-$VERSION-$RELEASE:$distrib"
  docker tag "$REGISTRY/mon-autodisco-$VERSION-$RELEASE:$distrib" "$REGISTRY/mon-autodisco-$TARGETVERSION:$distrib"
  docker push "$REGISTRY/mon-autodisco-$TARGETVERSION:$distrib"
done
