#!/bin/sh

set -x

docker build -t docker-sbuild-unstable-partial . &&
docker run -it --privileged --name docker-sbuild-unstable-partial-container docker-sbuild-unstable-partial sh prepare_subchroot.sh &&
docker commit docker-sbuild-unstable-partial-container amubtdx/debian-sbuild-unstable &&
docker rm docker-sbuild-unstable-partial-container &&
docker image remove docker-sbuild-unstable-partial

