#!/bin/sh
set -e

if [ -z "$VERSION" -o -z "$RELEASE" -o -z "$DISTRIB" ] ; then
  echo "You need to specify VERSION / RELEASE variables"
  exit 1
fi

echo "################################################## PACKAGING COLLECT ##################################################"

AUTHOR="Luiz Costa"
AUTHOR_EMAIL="me@luizgustavo.pro.br"

if ! [ -d ../repo ]; then
    rm -rf ./repo
fi

# mkdir -p centreon-collect
# cp -rv * centreon-collect
rm -rf centreon-collect/debian
rm -rf centreon-collect/build
tar czpvf centreon-collect-$VERSION.tar.gz centreon-collect
cd centreon-collect/
mv ci/debian .
debmake -f "${AUTHOR}" -e "${AUTHOR_EMAIL}" -u "$VERSION" -r "$RELEASE"
debuild-pbuilder
cd ../
mkdir $DISTRIB
mv *.deb $DISTRIB/