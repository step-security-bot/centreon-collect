# Create input and output directories for docker-rpm-builder.
rm -rf input
mkdir input
rm -rf output
mkdir output

# Retrieve source tarball, spectemplate and additional source files.
mv "$PROJECT-$VERSION.tar.gz" input/
cp `dirname $0`/../../../packaging/engine/21.10/centreon-engine.spectemplate input/
cp `dirname $0`/../../../packaging/engine/centreonengine_integrate_centreon_engine2centreon.sh input/

# Build RPMs.
docker-rpm-builder dir --sign-with `dirname $0`/../../ces.key registry.centreon.com/mon-build-dependencies-21.10:opensuse-leap input output

# Publish RPMs.
put_internal_rpms "21.10" "leap" "x86_64" "engine" "$PROJECT-$VERSION-$RELEASE" output/x86_64/*.rpm
