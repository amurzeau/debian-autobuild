#!/bin/sh

set -x

target_dist=${1:-"unstable"}

docker build -t docker-sbuild-$target_dist-partial . &&
	docker run -it --privileged --name docker-sbuild-$target_dist-partial-container \
	-v "$PWD/debootstrap_docker.sh:/debootstrap_docker.sh" \
	-v "$PWD/buildpackage.py.patch:/buildpackage.py.patch" \
	docker-sbuild-$target_dist-partial sh debootstrap_docker.sh $target_dist &&
docker commit docker-sbuild-$target_dist-partial-container amubtdx/debian-sbuild-$target_dist &&
docker rm docker-sbuild-$target_dist-partial-container &&
docker image remove docker-sbuild-$target_dist-partial

