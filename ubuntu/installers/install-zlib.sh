#!/usr/bin/env bash

set -euo pipefail

ZLIB_VERSION="v1.3.1"

ZLIB_URL="https://github.com/madler/zlib.git"
ZLIB_SRC="zlib-src"

# Download ZLIB sources.
git clone "${ZLIB_URL}" -b "${ZLIB_VERSION}" "${ZLIB_SRC}"

# Set working directory to ZLIB sources.
pushd "${ZLIB_SRC}"

# Build ZLIB.
./configure --prefix="${EDUCONTAINER_ZLIB}"
make -j"$(nproc --all)"

# If BUILD_EXTRAS_RUN_TESTS == true, then we should test ZLIB.
if $BUILD_EXTRAS_RUN_TESTS
then
  ## Test ZLIB.
  make test
fi

# Install ZLIB.
make install

# Go back.
popd

# Remove sources.
rm -rf "${ZLIB_SRC}"
