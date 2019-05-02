#!/bin/sh

set -e
set -x

. `dirname $0`/../../common.sh

# Project.
PROJECT=centreon-map

# Check arguments.
if [ -z "$VERSION" -o -z "$RELEASE" ] ; then
  echo "You need to specify VERSION and RELEASE environment variables."
  exit 1
fi


#
# Release delivery.
#
if [ "$BUILD" '=' 'RELEASE' ] ; then
  if [ "$PRODUCT" '=' 'desktop' -o "$PRODUCT" '=' 'all' ] ; then
    copy_internal_source_to_testing "map" "map-desktop" "$PROJECT-$VERSION-$RELEASE"
  fi
  if [ "$PRODUCT" '=' 'server' -o "$PRODUCT" '=' 'all' ] ; then
    copy_internal_rpms_to_testing "map" "19.10" "el7" "noarch" "map-server" "$PROJECT-$VERSION-$RELEASE"
  fi
  if [ "$PRODUCT" '=' 'web' -o "$PRODUCT" '=' 'all' ] ; then
    copy_internal_rpms_to_testing "map" "19.10" "el7" "noarch" "map-web" "$PROJECT-$VERSION-$RELEASE"
  fi
  SSH_DOC="ssh -o StrictHostKeyChecking=no root@doc-dev.int.centreon.com"
  $SSH_DOC bash -c "'source /srv/env/documentation/bin/activate ; /srv/prod/readthedocs.org/readthedocs/manage.py update_repos centreon-map-4 -V latest'"

#
# CI delivery.
#
else
  # Tag and push images.
  REGISTRY='registry.centreon.com'
  for image in des-map-server des-map-web ; do
    for distrib in centos7 ; do
      docker pull "$REGISTRY/$image-$VERSION-$RELEASE:$distrib"
      docker tag "$REGISTRY/$image-$VERSION-$RELEASE:$distrib" "$REGISTRY/$image-19.10:$distrib"
      docker push "$REGISTRY/$image-19.10:$distrib"
    done
  done

  # Move RPMs to unstable.
  promote_canary_rpms_to_unstable "map" "19.10" "el7" "noarch" "map-web" "$PROJECT-$VERSION-$RELEASE"
  promote_canary_rpms_to_unstable "map" "19.10" "el7" "noarch" "map-server" "$PROJECT-$VERSION-$RELEASE"
fi
