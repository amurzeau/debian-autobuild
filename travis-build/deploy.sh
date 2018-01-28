#!/bin/bash

bintray_repository="${1:-debian}"
CHROOT_ALIAS=${2:-stable}
CHANGES_FILE=${3}

echo "Deploying on bintray repository $bintray_repository"

sudo apt-get install -y --no-install-recommends python3 python3-debian python3-requests
python3 $(dirname "$0")/bintray_upload_changes.py amurzeau $bintray_repository $CHROOT_ALIAS ${CHANGES_FILE}
