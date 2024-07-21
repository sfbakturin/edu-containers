#!/usr/bin/env bash

set -euo pipefail

GTEST_VERSION="v1.14.0"

GTEST_URL="https://github.com/google/googletest.git"
GTEST_SRC="gtest-src"

GTEST_TEST='OFF'

# If BUILD_EXTRAS_RUN_TESTS == true, then we should build tests.
if $BUILD_EXTRAS_RUN_TESTS
then
  GTEST_TEST='ON'
fi

# Download GoogleTest sources.
git clone "${GTEST_URL}" -b "${GTEST_VERSION}" "${GTEST_SRC}"

# Set working directory to GoogleTest sources.
pushd "${GTEST_SRC}"

# Build GoogleTest.
cmake . -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="${EDUCONTAINER_GOOGLETEST}" -D gtest_build_tests="${GTEST_TEST}"
make -j"$(nproc --all)"

# If BUILD_EXTRAS_RUN_TESTS == true, then we should test GoogleTest.
if $BUILD_EXTRAS_RUN_TESTS
then
  ## Test GoogleTest.
  make test
fi

# Install GoogleTest.
make install

# Go back.
popd

# Remove sources.
rm -rf "${GTEST_SRC}"
