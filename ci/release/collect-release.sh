#!/bin/bash
set -e 
set -x

source common.sh

# Check arguments
if [ -z "$VERSION" -o -z "$RELEASE" ] ; then
  echo "You need to specify VERSION / RELEASE variables"
  exit 1
fi

MAJOR=`echo $VERSION | cut -d . -f 1,2`

# Move RPMs to the stable repository.
promote_rpms_from_testing_to_stable "standard" "$MAJOR" "el7" "x86_64" "broker" "centreon-broker-$VERSION-$RELEASE"
promote_rpms_from_testing_to_stable "standard" "$MAJOR" "el8" "x86_64" "broker" "centreon-broker-$VERSION-$RELEASE"
promote_rpms_from_testing_to_stable "standard" "$MAJOR" "el7" "x86_64" "engine" "centreon-engine-$VERSION-$RELEASE"
promote_rpms_from_testing_to_stable "standard" "$MAJOR" "el8" "x86_64" "engine" "centreon-engine-$VERSION-$RELEASE"
promote_rpms_from_testing_to_stable "standard" "$MAJOR" "el7" "x86_64" "clib" "centreon-clib-$VERSION-$RELEASE"
promote_rpms_from_testing_to_stable "standard" "$MAJOR" "el8" "x86_64" "clib" "centreon-clib-$VERSION-$RELEASE"
promote_rpms_from_testing_to_stable "standard" "$MAJOR" "el7" "x86_64" "connector" "centreon-connector-$VERSION-$RELEASE"
promote_rpms_from_testing_to_stable "standard" "$MAJOR" "el8" "x86_64" "connector" "centreon-connector-$VERSION-$RELEASE"
