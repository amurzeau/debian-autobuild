#!/bin/sh

set -ex

ARCH="$1"
DIST="$2"
CHECKOUT_DIR="$3"

eatmydata apt-get -y update
eatmydata apt-get -y dist-upgrade
eatmydata apt-get -y autoremove


# Fix 'fatal: unsafe repository ('/build/checkout-dir' is owned by someone else)'
git config --global --add safe.directory /build/checkout-dir

# Download orig.tar.* archives to ../
cd "$CHECKOUT_DIR"
if ! gbp export-orig --verbose; then
    git status || true
    origtargz --unpack=no --tar-only
fi
cd -

# Reenable apt archive cache to download dependencies only once for both the source clean and sbuild build
[ -f /etc/apt/apt.conf.d/docker-clean ] && mv /etc/apt/apt.conf.d/docker-clean /etc/apt/apt.conf.d/docker-clean.disabled

# Install dependencies for debian/rules clean only (remove them after to keep disk usage low)
eatmydata mk-build-deps --install --remove --tool "apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends -y" "$CHECKOUT_DIR/debian/control"
eatmydata fakeroot make -C $CHECKOUT_DIR -f debian/rules clean
eatmydata apt-get remove --auto-remove -y "$(dpkg-parsechangelog -l "$CHECKOUT_DIR/debian/changelog" --show-field Source)-build-deps"

df -h

sbuild -v --arch-all --no-source --no-clean-source --host $ARCH --build $ARCH -d $DIST "$CHECKOUT_DIR"
