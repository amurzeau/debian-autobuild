#!/bin/bash

set -xe

REPO="$1"
VERSION="$2"
ARCH="$3"

CHECKOUT_DIR="checkout-dir"

echo "Building $REPO version $VERSION on arch $ARCH"

echo $LANG
echo $LC_ALL
echo $USER
git clone -b "$VERSION" --depth 1 "$REPO" "$CHECKOUT_DIR"

export TARGET_DIST=$(dpkg-parsechangelog -l "$CHECKOUT_DIR/debian/changelog" --show-field distribution)
export DIST=$([ "$TARGET_DIST" != "UNRELEASED" ] && [ "$TARGET_DIST" != "experimental" ] && (echo "$TARGET_DIST" | cut -d '-' -f 1) || echo "unstable")

docker build --build-arg TARGET_DIST=$DIST --build-arg TARGET_ARCH=$ARCH --tag docker-debian-sbuild-$DIST-$ARCH ./docker-image
docker image prune -f
docker image ls

echo "::set-output docker-image-tag=docker-debian-sbuild-$DIST-$ARCH"

echo "Building for distribution $DIST ($TARGET_DIST)"
mkdir -p build-area
docker run --rm --privileged \
    -v $PWD:/build \
    -w /build \
    docker-debian-sbuild-$DIST-$ARCH \
    /build/scripts/build-package.sh "$ARCH" "$DIST" "$CHECKOUT_DIR"

export CHANGES_FILE="$(find . -maxdepth 1 -type f -name '*.changes' -printf '%T@ %P\n' | sort -nr | awk '{print $2}' | head -1)"
echo "$CHANGES_FILE"
cat "$CHANGES_FILE"
