#!/bin/sh

set -x

DIST=${1:-"unstable"}
SOURCE_DIR=${2:-"$PWD/streamlink"}

docker pull amubtdx/debian-sbuild-$DIST

docker run --rm --privileged -v $PWD/../build-area:/build/build-area -v $SOURCE_DIR:/build/source -w /build/source -it amubtdx/debian-sbuild-$DIST \
	bash -c "apt-get -y update && apt-get -y dist-upgrade && apt-get -y autoremove && \
       gbp buildpackage --git-verbose --git-ignore-branch --git-cleaner= \"--git-builder=sbuild -v -As -d $DIST --no-clean-source --run-lintian --lintian-opts=\\\"-EviIL +pedantic\\\" --run-autopkgtest --autopkgtest-root-args= --autopkgtest-opts=\\\"-- schroot %r-%a-sbuild\\\"\""

