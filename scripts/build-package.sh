#!/bin/sh

set -ex

ARCH="$1"
DIST="$2"
CHECKOUT_DIR="$3"

apt-get -y update
apt-get -y dist-upgrade
apt-get -y autoremove

# Install dependencies for clean
mk-build-deps --install --remove --tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" "$CHECKOUT_DIR/debian/control"

# Download orig.tar.* archives to ../
cd "$CHECKOUT_DIR"
origtargz --unpack=no --tar-only
cd -

sbuild -v --arch-all --no-source --host $ARCH --build $ARCH -d $DIST "$CHECKOUT_DIR"
