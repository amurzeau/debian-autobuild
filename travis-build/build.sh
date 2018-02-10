#!/bin/sh

set -x

DIST=$1

apt-get -y update &&
	apt-get -y dist-upgrade &&
	apt-get -y autoremove &&
	printf "override_dh_builddeb:\n\tdh_builddeb -- -Zgzip\n" >> debian/rules &&
	dch -M -l '~bintray' -u low "Rebuild for bintray" -D $DIST &&
	git add debian/rules debian/changelog &&
	git -c user.name='travis build' -c user.email='travis@example.com' commit -m "Rebuild for bintray" &&
	gbp buildpackage --git-verbose --git-ignore-branch --git-cleaner= "--git-builder=sbuild -v -As -d $DIST --no-clean-source --run-lintian --lintian-opts=\"-EviIL +pedantic\" --run-autopkgtest --autopkgtest-root-args= --autopkgtest-opts=\"-- schroot %r-%a-sbuild\""
