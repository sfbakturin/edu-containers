#!/bin/bash

set -euo pipefail

GCC_PPA_URL="ppa:ubuntu-toolchain-r/test"

# Include the GCC PPA to apt list.
add-apt-repository "${GCC_PPA_URL}"
apt-get update

# Install a specific version of GCC.
apt-get install -y --no-install-recommends gcc-"${COMPILER_VERSION}" g++-"${COMPILER_VERSION}"

# Link standard CC and CXX to clang.
ln -sf /usr/bin/gcc-"${COMPILER_VERSION}" /usr/bin/cc
ln -sf /usr/bin/g++-"${COMPILER_VERSION}" /usr/bin/c++
