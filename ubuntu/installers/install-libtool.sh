#!/bin/bash

set -euo pipefail

LIBTOOL_VERSION="2.4.7"
LIBTOOL_SRC="libtool-${LIBTOOL_VERSION}"
LIBTOOL_TAR="${LIBTOOL_SRC}.tar.gz"
LIBTOOL_URL="https://ftpmirror.gnu.org/libtool"

# Download and extract libtool sources.
wget "${LIBTOOL_URL}"/"${LIBTOOL_TAR}"
tar -xf "${LIBTOOL_TAR}"
rm "${LIBTOOL_TAR}"

# Set working directory to libtool sources.
pushd "${LIBTOOL_SRC}"

# Build and install libtool.
./configure
make -j"$(nproc --all)"
make install

# Go back.
popd

# Remove sources.
rm -rf "${LIBTOOL_SRC}"
