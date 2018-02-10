FROM debian:stable

RUN apt-get update && \
	apt-get install -y --no-install-recommends sbuild schroot gnupg lintian autopkgtest dpkg-dev git-buildpackage pristine-tar && \
	apt-get clean
