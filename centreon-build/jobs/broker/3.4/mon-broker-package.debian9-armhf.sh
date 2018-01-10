# Prepare build directory.
rm -rf debuildir
mkdir debuildir
cp "${PROJECT}-${VERSION}.tar.gz" "debuildir/${PROJECT}_${VERSION}.orig.tar.gz"
cd debuildir
tar xzf "${PROJECT}_${VERSION}.orig.tar.gz"
cp -r "../packaging-${PROJECT}/debian" "${PROJECT}-${VERSION}/"
sed -e "s/@VERSION@/${VERSION}/g" -e "s/@RELEASE@/${RELEASE}/g" < "${PROJECT}-${VERSION}/debian/changelog.in" > "${PROJECT}-${VERSION}/debian/changelog"
cd ..

# Launch debuild.
containerid=`docker create ci.int.centreon.com:5000/mon-build-dependencies:debian9-armhf sh -c "cd /usr/local/src/debuildir/${PROJECT}-${VERSION} && export CC=arm-linux-gnueabihf-gcc && export CXX=arm-linux-gnueabihf-g++ && dpkg-buildpackage -us -uc -d -aarmhf"`
docker cp debuildir "$containerid:/usr/local/src/debuildir"
docker start -a "$containerid"

# Send package to repository.
docker cp "$containerid:/usr/local/src/debuildir/${PROJECT}_${VERSION}-${RELEASE}_armhf.deb" .
put_internal_debs "3.5" "stretch" *.deb

# Stop container.
docker stop "$containerid"
docker rm "$containerid"
