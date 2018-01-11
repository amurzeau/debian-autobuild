#!/bin/sh

set -x

DIST=${1:-"unstable"}
SOURCE_DIR=${2:-"$PWD/streamlink"}

docker pull amubtdx/debian-sbuild-$DIST

schroot_dir=$(mktemp -d -t schroot_docker_build_XXXXXXX)
mkdir -p $schroot_dir/session $schroot_dir/union/overlay $schroot_dir/union/underlay $schroot_dir/unpack

docker run --rm --privileged -v $PWD/../build-area:/build/build-area -v $schroot_dir:/var/lib/schroot -v $schroot_dir:/var/lib/schroot -v $SOURCE_DIR:/build/source -w /build/source -it amubtdx/debian-sbuild-$DIST \
       gbp buildpackage --git-verbose --git-ignore-branch --git-cleaner= "--git-builder=sbuild -v -As -d $DIST --no-clean-source --run-lintian --lintian-opts=\"-EviIL +pedantic\" --run-autopkgtest --autopkgtest-root-args= --autopkgtest-opts=\"-- schroot %r-%a-sbuild\""

rm -r "$schroot_dir"
