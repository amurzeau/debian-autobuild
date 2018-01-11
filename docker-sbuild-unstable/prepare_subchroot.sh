#!/bin/sh

set -x

apt-get install -y --no-install-recommends debootstrap &&
(sbuild-createchroot --arch=amd64 unstable ~/chroot/ http://ftp.de.debian.org/debian/ || (cat /root/chroot/debootstrap/debootstrap.log && exit 1)) &&
	chown -R _apt:root ~/chroot/var/lib/apt/lists/partial &&
	apt-get purge -y debootstrap &&
	apt-get clean &&
	bash -c "echo 'aliases=$CHROOT_ALIAS' >> /etc/schroot/chroot.d/$CHROOT_NAME*" &&
	bash -c "sed -i 's/union-type=.*/union-type=overlay/' /etc/schroot/chroot.d/$CHROOT_NAME*" &&
	bash -c "patch /usr/lib/python2.7/dist-packages/gbp/scripts/buildpackage.py < buildpackage.py.patch"
