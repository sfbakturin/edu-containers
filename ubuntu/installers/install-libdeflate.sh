#!/usr/bin/env bash

set -euo pipefail

LIBDEFLATE_VERSION="v1.20"

LIBDEFLATE_URL="https://github.com/ebiggers/libdeflate.git"
LIBDEFLATE_SRC="libdeflate-src"

# Download libdeflate sources.
git clone "${LIBDEFLATE_URL}" -b "${LIBDEFLATE_VERSION}" "${LIBDEFLATE_SRC}"

# Set working directory to libdeflate sources.
pushd "${LIBDEFLATE_SRC}"

# Build libdeflate.
cmake . -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX="${EDUCONTAINER_LIBDEFLATE}" -D ZLIB_ROOT="${EDUCONTAINER_ZLIB}" -D LIBDEFLATE_BUILD_TESTS=ON
make -j"$(nproc --all)"

# If RUN_TESTS == true, then we should test libdeflate.
if $RUN_TESTS
then
  ## Set working directory to libdeflate tests.
  pushd programs

  ## Test libdeflate.
  ./test_checksums
  ./test_custom_malloc
  ./test_incomplete_codes
  ./test_invalid_streams
  ./test_litrunlen_overflow
  ./test_overread
  ./test_slow_decompression
  ./test_trailing_bytes

  ## Go back.
  popd
fi

# Install libdeflate.
make install

# Go back.
popd

# Remove sources.
rm -rf "${LIBDEFLATE_SRC}"
