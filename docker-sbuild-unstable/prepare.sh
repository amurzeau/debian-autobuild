#!/bin/sh

set -x

apt-get update &&
apt-get install -y --no-install-recommends sbuild schroot gnupg lintian autopkgtest dpkg-dev git-buildpackage pristine-tar &&
apt-get clean &&
(id -u _apt > /dev/null 2>&1 || sudo adduser --force-badname --system --home /nonexistent --no-create-home --quiet _apt || true)

