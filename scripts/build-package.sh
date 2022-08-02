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
    origtargz --unpack=no --tar-only
fi
cd -

# Install dependencies for clean
mk-build-deps --install --remove --tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" "$CHECKOUT_DIR/debian/control"

sbuild -v --arch-all --no-source --host $ARCH --build $ARCH -d $DIST "$CHECKOUT_DIR"
