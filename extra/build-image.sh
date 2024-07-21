#!/usr/bin/env bash

if test "$#" -ne 3
then
    echo "Illegal number of parameters"
    exit 1
fi

COMPILER_NAME="${1}"
COMPILER_NAMEXX="${2}"
COMPILER_VERSION="${3}"
BASE_IMAGE_TAG="${COMPILER_NAME}-${COMPILER_VERSION}"

FULL_TAG="${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}"

docker build --tag "${FULL_TAG}" \
             --build-arg COMPILER_NAME=${COMPILER_NAME} \
             --build-arg COMPILER_NAMEXX=${COMPILER_NAMEXX} \
             --build-arg COMPILER_VERSION=${COMPILER_VERSION} \
             --build-arg RUN_TESTS=${RUN_TESTS} \
             -f ubuntu/Dockerfile .
