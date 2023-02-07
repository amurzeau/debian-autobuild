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

# Shallow clone the wanted branch and pristine-tar if it exists
mkdir "$CHECKOUT_DIR"
cd "$CHECKOUT_DIR"
git init
git remote add origin "$REPO"
git fetch --depth 1 origin "$VERSION:$VERSION"
git fetch --depth 1 origin pristine-tar:pristine-tar && git fetch --depth 1 origin upstream:upstream || true
git checkout "$VERSION"
cd -

export TARGET_DIST=$(dpkg-parsechangelog -l "$CHECKOUT_DIR/debian/changelog" --show-field distribution)
export DIST=$([ "$TARGET_DIST" != "UNRELEASED" ] && [ "$TARGET_DIST" != "experimental" ] && (echo "$TARGET_DIST" | cut -d '-' -f 1) || echo "unstable")

docker build --pull --build-arg TARGET_DIST=$DIST --build-arg TARGET_ARCH=$ARCH --tag docker-debian-sbuild-$DIST-$ARCH ./docker-image

# Maximize disk space
# Do this only if the git dir is large (> 500MB)
if [ "$(du -s "$CHECKOUT_DIR/.git" | cut -d $'\t' -f 1)" -gt 500000 ]; then
    docker image rm $(docker images -q --format "{{.ID}}\t{{.Repository}}" | grep -v -e docker-debian-sbuild | cut -d $'\t' -f1) || true
    docker image prune -f || true
    
    # Should free around 30GB (see https://github.com/actions/virtual-environments/issues/2606)
    [ -d "/usr/share/dotnet" ] && sudo rm -rf "/usr/share/dotnet" || true
    [ -d "/usr/local/lib/android" ] && sudo rm -rf "/usr/local/lib/android" || true
fi

docker system df -v
df -h
free -h

echo "::set-output docker-image-tag=docker-debian-sbuild-$DIST-$ARCH"

echo "Building for distribution $DIST ($TARGET_DIST)"
mkdir -p build-area
docker run --rm --privileged \
    -v $PWD:/build \
    -w /build \
    docker-debian-sbuild-$DIST-$ARCH \
    /build/scripts/build-package.sh "$ARCH" "$DIST" "$CHECKOUT_DIR"

df -h
free -h

export CHANGES_FILE="$(find . -maxdepth 1 -type f -name '*.changes' -printf '%T@ %P\n' | sort -nr | awk '{print $2}' | head -1)"
echo "$CHANGES_FILE"
cat "$CHANGES_FILE"
