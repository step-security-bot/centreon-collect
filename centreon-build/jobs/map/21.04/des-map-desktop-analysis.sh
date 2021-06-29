#!/bin/sh

set -e
set -x

. `dirname $0`/../../common.sh

# Project.
PROJECT=centreon-map

# Copy reports and run analysis.
cd "$PROJECT-desktop-$VERSION"
if [ "$BUILD" '=' 'RELEASE' ] ; then
  sed -i -e 's/centreon-map-desktop-21.04/centreon-map-desktop-21.04-release/g' sonar-project.properties
  sed -i -e 's/Centreon Map Desktop 21.04/Centreon Map Desktop 21.04 (release)/g' sonar-project.properties
fi
echo "sonar.projectVersion=$VERSION" >> sonar-project.properties
# override missing AMI requirement
sudo apt-get install shellcheck
sonar-scanner
