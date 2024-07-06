#!/bin/bash

BASE_IMAGE_PREFIX=ubuntu:noble
BASE_IMAGE_DATE=-20240605
BASE_IMAGE="${BASE_IMAGE_PREFIX}${BASE_IMAGE_DATE}"

# NOTE: the Ubuntu distro codename will become the image's tag.
IMAGE_NAME=emacs/$BASE_IMAGE_PREFIX

## --------------------

fullName="$IMAGE_NAME"
echo "Building Docker image '$fullName'..." 1>&2

export DOCKER_BUILDKIT=1
exec docker build \
       --tag "$fullName" \
       --build-arg BASE_IMAGE="$BASE_IMAGE" \
       --build-arg USER="$USER" --build-arg UID="$(id -u)" \
       -f "./Dockerfile" \
       .
