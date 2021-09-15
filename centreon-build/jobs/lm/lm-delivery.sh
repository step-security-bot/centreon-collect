#!/bin/sh

set -e

. `dirname $0`/../common.sh

# Project.
PROJECT=centreon-license-manager

# Check arguments.
if [ -z "$VERSION" -o -z "$RELEASE" ] ; then
  echo "You need to specify VERSION and RELEASE environment variables."
  exit 1
fi

MAJOR=`echo $VERSION | cut -d . -f 1,2`
EL7RPMS=`echo output/x86_64/*.el7.*.rpm`
EL8RPMS=`echo output/x86_64/*.el8.*.rpm`

# Publish RPMs.
if [ "$BUILD" '=' 'QA' ]
then
  put_rpms "standard" "$MAJOR" "el7" "unstable" "x86_64" "lm" "$PROJECT-$VERSION-$RELEASE" $EL7RPMS
  put_rpms "standard" "$MAJOR" "el8" "unstable" "x86_64" "lm" "$PROJECT-$VERSION-$RELEASE" $EL8RPMS
elif [ "$BUILD" '=' 'RELEASE' ]
then
  copy_internal_source_to_testing "standard" "lm" "$PROJECT-$VERSION-$RELEASE"
  put_rpms "standard" "$MAJOR" "el7" "testing" "x86_64" "lm" "$PROJECT-$VERSION-$RELEASE" $EL7RPMS
  put_rpms "standard" "$MAJOR" "el8" "testing" "x86_64" "lm" "$PROJECT-$VERSION-$RELEASE" $EL8RPMS
fi

# Set Docker images as latest.
REGISTRY='registry.centreon.com'
for distrib in centos7 centos8 ; do
  docker pull "$REGISTRY/mon-lm-$VERSION-$RELEASE:$distrib"
  docker tag "$REGISTRY/mon-lm-$VERSION-$RELEASE:$distrib" "$REGISTRY/mon-lm-$TARGETVERSION:$distrib"
  docker push "$REGISTRY/mon-lm-$TARGETVERSION:$distrib"
done
