#!/bin/sh

set -x

target_dist=${1:-"unstable"}

bash -c "patch /usr/lib/python2.7/dist-packages/gbp/scripts/buildpackage.py < buildpackage.py.patch"

apt-get install -y --no-install-recommends debootstrap &&
(sbuild-createchroot --arch=amd64 --make-sbuild-tarball=~/unstable-amd64-sbuild.tar.gz --alias=UNRELEASED $target_dist ~/chroot/ http://ftp.de.debian.org/debian/ || (cat ~/chroot/debootstrap/debootstrap.log && exit 1)) &&
	apt-get purge -y debootstrap &&
	apt-get clean
