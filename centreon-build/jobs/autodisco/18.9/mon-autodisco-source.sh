#!/bin/sh

set -e
set -x

. `dirname $0`/../../common.sh

#
# This script will generate sources from the local clone of the project
# repository. These sources will then be pushed to the internal
# repository (srvi-repo) and used in downstream jobs, thanks to the
# property file generated at the end of the script.
#

# Project.
PROJECT=centreon-autodiscovery

# Get version.
cd "$PROJECT"
VERSION=`grep mod_release www/modules/centreon-autodiscovery-server/conf.php | cut -d '"' -f 4`
export VERSION="$VERSION"

# Get release.
COMMIT=`git log -1 HEAD --pretty=format:%h`
now=`date +%s`
export RELEASE="$now.$COMMIT"

# Get committer.
COMMITTER=`git show --format='%cN <%cE>' HEAD | head -n 1`

# Create source tarballs (f*cking .gitattributes).
git archive --prefix="$PROJECT-$VERSION/" HEAD | gzip > "../$PROJECT-$VERSION.tar.gz"
cd ..

# Send it to srvi-repo.
curl -F "file=@$PROJECT-$VERSION.tar.gz" -F "version=71" 'http://encode.int.centreon.com/api/index.php' -o "$PROJECT-$VERSION-php71.tar.gz"
put_internal_source "autodisco" "$PROJECT-$VERSION-$RELEASE" "$PROJECT-$VERSION.tar.gz"
put_internal_source "autodisco" "$PROJECT-$VERSION-$RELEASE" "$PROJECT-$VERSION-php71.tar.gz"

# Generate properties files for downstream jobs.
cat > source.properties << EOF
PROJECT=$PROJECT
VERSION=$VERSION
RELEASE=$RELEASE
COMMIT=$COMMIT
COMMITTER=$COMMITTER
EOF
