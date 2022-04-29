#!/bin/bash
set -e

if [ -z "$VERSION" -o -z "$RELEASE" -o -z "$DISTRIB" ] ; then
  echo "You need to specify VERSION / RELEASE / DISTRIB variables"
  exit 1
fi

echo "########################### BUILDING COLLECT ############################"

# generate rpm broker
if [ ! -d /root/rpmbuild/SOURCES ] ; then
    mkdir -p /root/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
fi

tar czf /root/rpmbuild/SOURCES/centreon-collect-$VERSION.tar.gz \
      --exclude './build' \
      --exclude './.git'  \
      --transform "s,^\.,centreon-collect-$VERSION," .

cp packaging/rpm/centreonengine_integrate_centreon_engine2centreon.sh /root/rpmbuild/SOURCES/

DISTRIB=$(lsb_release -rs | cut -f1 -d.)
if [ "$DISTRIB" = "7" ] ; then
    source /opt/rh/devtoolset-9/enable
fi 

echo -e "%_topdir      %(echo $HOME)/rpmbuild\n%_smp_mflags  -j9\n" > $HOME/rpmbuild/.rpmmacros

rpmbuild -ba packaging/rpm/centreon-collect.spec -D "VERSION $VERSION" -D "RELEASE $RELEASE"

# cleaning and according permissions to slave to delivery rpms
rm -rf *.rpm
cp -r /root/rpmbuild/RPMS/x86_64/*.rpm .
chmod 777 *.rpm
