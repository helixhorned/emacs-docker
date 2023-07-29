#!/bin/bash

source_rcu_tar="$1"

BASE_IMAGE_PREFIX=ubuntu:mantic
BASE_IMAGE_DATE=-20230712
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
