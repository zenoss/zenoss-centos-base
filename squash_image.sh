#!/bin/bash

if [ $# -ne 2 ]; then
	echo "usage: $0 SOURCE-IMAGE TARGET-IMAGE" >&2
	exit 1
fi

SRC=$1
DST=$2

if [ "${SRC}" == "${DST}" ]; then
	echo "Source and target images cannot have identical names: ${SRC}" >&2
	exit 1
fi

SRC_EXISTS=$(docker image list --format '{{.Repository}}:{{.Tag}}' ${SRC})
if [ -z "${SRC_EXISTS}" ]; then
	echo "Source image, ${SRC}, does not exist." >&2
	exit 1
fi

DST_EXISTS=$(docker image list --format '{{.Repository}}:{{.Tag}}' ${DST})
if [ -n "${DST_EXISTS}" ]; then
	echo "Target image, ${DST}, already exists." >&2
	exit 1
fi

CONTAINER=image-squasher

CONTAINER_EXISTS=$(docker container list -a --format '{{.Names}}' | grep ${CONTAINER})
if [ -n "${CONTAINER_EXISTS}" ]; then
	docker container rm ${CONTAINER}
fi

echo Squashing ${SRC} into ${DST}...

docker container create --name ${CONTAINER} ${SRC} echo
docker container export ${CONTAINER} | docker image import - ${DST}
docker container rm ${CONTAINER}
