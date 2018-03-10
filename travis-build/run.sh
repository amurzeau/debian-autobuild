#!/bin/sh

set -x

DIST=${1:-"unstable"}
SOURCE_DIR=${2:-"$PWD/streamlink"}

docker pull amubtdx/debian-sbuild-$DIST

docker run --rm --privileged \
	-v $PWD/../travis-build:/build/scripts \
	-v $PWD/../build-area:/build/build-area \
	-v $SOURCE_DIR:/build/source \
	-w /build/source \
	-it amubtdx/debian-sbuild-$DIST \
	bash /build/scripts/build.sh $DIST

