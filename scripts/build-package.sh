#!/bin/sh

set -ex

ARCH="$1"
DIST="$2"
CHECKOUT_DIR="$3"

apt-get -y update
apt-get -y dist-upgrade
apt-get -y autoremove

# Download orig.tar.* archives to ../
cd "$CHECKOUT_DIR"
if ! gbp export-orig --verbose; then
    ls -la
    origtargz --unpack=no --tar-only
fi
cd -

# Install dependencies for debian/rules clean only (remove them after to keep disk usage low)
mk-build-deps --install --remove --tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" "$CHECKOUT_DIR/debian/control"
fakeroot make -C $CHECKOUT_DIR -f debian/rules clean
apt-get remove --auto-remove -y "$(dpkg-parsechangelog -l "$CHECKOUT_DIR/debian/changelog" --show-field Source)-build-deps"

df -h

sbuild -v --arch-all --no-source --no-clean-source --host $ARCH --build $ARCH -d $DIST "$CHECKOUT_DIR"
