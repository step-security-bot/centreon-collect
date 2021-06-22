#!/bin/sh

set -e
set -x

. `dirname $0`/../../common.sh

# Project.
PROJECT=centreon-agent

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

# Create input and output directories.
rm -rf input
mkdir input
rm -rf output
mkdir output

# Fetch sources.
rm -rf "$PROJECT-$VERSION"
tar xzf "$PROJECT-$VERSION.tar.gz"

# Pull latest build dependencies.
BUILD_IMG="registry.centreon.com/build-dependencies-agent-2.1:$DISTRIB"
docker pull "$BUILD_IMG"

# Build RPMs.
cp "$PROJECT-$VERSION.tar.gz" input/
cp -r "$PROJECT-$VERSION/packaging/"* input/
docker-rpm-builder dir --sign-with `dirname $0`/../../ces.key "$BUILD_IMG" input output

# Copy files to server.
if [ "$DISTRIB" = 'centos7' ] ; then
  DISTRIB=el7
elif [ "$DISTRIB" = 'centos8' ] ; then
  DISTRIB=el8
else
  echo "Unsupported distribution $DISTRIB."
  exit 1
fi
if [ "$DISTRIB" = el7 ] ; then
  put_internal_rpms "20.04" "$DISTRIB" "x86_64" "agent" "$PROJECT-$VERSION-$RELEASE" output/x86_64/*.rpm
fi
put_internal_rpms "20.10" "$DISTRIB" "x86_64" "agent" "$PROJECT-$VERSION-$RELEASE" output/x86_64/*.rpm
put_internal_rpms "21.04" "$DISTRIB" "x86_64" "agent" "$PROJECT-$VERSION-$RELEASE" output/x86_64/*.rpm
put_internal_rpms "21.10" "$DISTRIB" "x86_64" "agent" "$PROJECT-$VERSION-$RELEASE" output/x86_64/*.rpm
if [ "$BUILD" '=' 'REFERENCE' ] ; then
  if [ "$DISTRIB" = el7 ] ; then
    copy_internal_rpms_to_canary "standard" "20.04" "$DISTRIB" "x86_64" "agent" "$PROJECT-$VERSION-$RELEASE"
  fi
  copy_internal_rpms_to_canary "standard" "20.10" "$DISTRIB" "x86_64" "agent" "$PROJECT-$VERSION-$RELEASE"
  copy_internal_rpms_to_canary "standard" "21.04" "$DISTRIB" "x86_64" "agent" "$PROJECT-$VERSION-$RELEASE"
  copy_internal_rpms_to_canary "standard" "21.10" "$DISTRIB" "x86_64" "agent" "$PROJECT-$VERSION-$RELEASE"
fi
