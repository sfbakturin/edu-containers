#!/bin/bash

set -euo pipefail

ISAL_VERSION="v2.31.0"

ISAL_URL="https://github.com/intel/isa-l.git"
ISAL_SRC="isal-src"

# Download isa-l sources.
git clone "${ISAL_URL}" -b "${ISAL_VERSION}" "${ISAL_SRC}"

# Set working directory to isa-l sources.
pushd "${ISAL_SRC}"

# Build and install isa-l.
./autogen.sh
./configure --prefix="${EDU_ISAL}"
make -j"$(nproc --all)"
make install

# Go back.
popd

# Remove sources.
rm -rf "${ISAL_SRC}"
