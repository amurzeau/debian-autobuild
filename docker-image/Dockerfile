FROM debian:unstable

ARG TARGET_DIST
ARG TARGET_ARCH=amd64

RUN apt-get update \
	&& apt-get -y dist-upgrade \
	&& apt-get install -y --no-install-recommends \
		devscripts \
		equivs \
		eatmydata \
		sbuild \
		schroot \
		gnupg \
		dpkg-dev \
		git-buildpackage \
		pristine-tar \
		debootstrap \
	&& echo TARGET_ARCH=$TARGET_ARCH TARGET_DIST=$TARGET_DIST \
	&& (eatmydata sbuild-createchroot --verbose --arch=$TARGET_ARCH --alias=UNRELEASED --include=eatmydata --command-prefix=eatmydata $TARGET_DIST /sbuild-chroot/ || (cat /sbuild-chroot/debootstrap/debootstrap.log && exit 1)) \
	&& echo "/var/cache/apt/archives/  /var/cache/apt/archives/ none  rw,bind   0   0" >> /etc/schroot/sbuild/fstab \
	&& echo "deb-src http://deb.debian.org/debian unstable main" >> /etc/apt/sources.list \
	&& eatmydata apt-get purge -y debootstrap \
	&& eatmydata apt-get -y autoremove \
	&& apt-get clean
