#!/bin/bash

set -euo pipefail

GTEST_VERSION="v1.14.0"

GTEST_URL="https://github.com/google/googletest.git"
GTEST_SRC="gtest-src"

# Download GoogleTest sources.
git clone "${GTEST_URL}" -b "${GTEST_VERSION}" "${GTEST_SRC}"

# Set working directory to GoogleTest sources.
pushd "${GTEST_SRC}"

# Build, test and install GoogleTest.
cmake . -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="${EDU_GOOGLETEST}" -D gtest_build_tests=ON
make -j"$(nproc --all)"
make test
make install

# Go back.
popd

# Remove sources.
rm -rf "${GTEST_SRC}"
