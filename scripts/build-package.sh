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

df -h

sbuild -v --arch-all --no-source --no-clean-source --host $ARCH --build $ARCH -d $DIST "$CHECKOUT_DIR" --no-run-lintian --no-run-piuparts --no-run-autopkgtest
