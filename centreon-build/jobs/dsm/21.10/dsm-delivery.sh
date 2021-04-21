#!/bin/sh

set -e
set -x

. `dirname $0`/../../common.sh

# Project.
PROJECT=centreon-dsm

# Check arguments.
if [ -z "$VERSION" -o -z "$RELEASE" ] ; then
  echo "You need to specify VERSION and RELEASE environment variables."
  exit 1
fi

#
# Release delivery.
#
if [ "$BUILD" '=' 'RELEASE' ] ; then
  # Copy build artifacts.
  copy_internal_source_to_testing "standard" "dsm" "$PROJECT-$VERSION-$RELEASE"
  copy_internal_rpms_to_testing "standard" "21.10" "el7" "noarch" "dsm" "$PROJECT-$VERSION-$RELEASE"
  copy_internal_rpms_to_testing "standard" "21.10" "el8" "noarch" "dsm" "$PROJECT-$VERSION-$RELEASE"

#
# CI delivery.
#
else
  promote_canary_rpms_to_unstable "standard" "21.10" "el7" "noarch" "dsm" "$PROJECT-$VERSION-$RELEASE"
  promote_canary_rpms_to_unstable "standard" "21.10" "el8" "noarch" "dsm" "$PROJECT-$VERSION-$RELEASE"
fi
