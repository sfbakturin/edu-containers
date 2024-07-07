#!/bin/bash

set -euo pipefail

LIBDEFLATE_VERSION="v1.20"

LIBDEFLATE_URL="https://github.com/ebiggers/libdeflate.git"
LIBDEFLATE_SRC="libdeflate-src"

# Download libdeflate sources.
git clone "${LIBDEFLATE_URL}" -b "${LIBDEFLATE_VERSION}" "${LIBDEFLATE_SRC}"

# Set working directory to libdeflate sources.
pushd "${LIBDEFLATE_SRC}"

# Build and install libdeflate.
cmake . -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="${EDU_LIBDEFLATE}"
make -j"$(nproc --all)"
make install

# Go back.
popd

# Remove sources.
rm -rf "${LIBDEFLATE_SRC}"
