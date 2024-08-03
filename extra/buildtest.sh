#!/usr/bin/env bash

set -euo pipefail

if test "$#" -ne 3
then
    echo "Illegal number of parameters"
    exit 1
fi

COMPILER_NAME="${1}"
COMPILER_NAMEXX="${2}"
COMPILER_VERSION="${3}"

BASE_IMAGE_TAG="${COMPILER_NAME}${COMPILER_VERSION}"

IMAGE_NAME="${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"
CONTAINER_NAME='buildtest'

# Build image.
docker build --tag "${IMAGE_NAME}" \
             --build-arg BUILD_TARGET_NAME=${COMPILER_NAME} \
             --build-arg BUILD_TARGET_NAMEXX=${COMPILER_NAMEXX} \
             --build-arg BUILD_TARGET_VERSION=${COMPILER_VERSION} \
             --build-arg BUILD_EXTRAS_RUN_TESTS=${RUN_TESTS} \
             -f ubuntu/Dockerfile .

# Test image.
if $RUN_TESTS
then
    docker run -t -d --name "${CONTAINER_NAME}" "${IMAGE_NAME}"
    docker cp testing/. "${CONTAINER_NAME}":/student
    docker exec "${CONTAINER_NAME}" bash test.sh
fi
