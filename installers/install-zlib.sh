#!/bin/bash

set -euo pipefail

ZLIB_VERSION="v1.3.1"

ZLIB_URL="https://github.com/madler/zlib.git"
ZLIB_SRC="zlib-src"

# Download ZLIB sources.
git clone "${ZLIB_URL}" -b "${ZLIB_VERSION}" "${ZLIB_SRC}"

# Set working directory to ZLIB sources.
pushd "${ZLIB_SRC}"

# Build and install ZLIB.
./configure --prefix="${EDU_ZLIB}"
make -j"$(nproc --all)"
make install

# Go back.
popd

# Remove sources.
rm -rf "${ZLIB_SRC}"
