#!/usr/bin/env bash

set -euo pipefail

GCC_PPA_URL="ppa:ubuntu-toolchain-r/test"

# Include the GCC PPA to apt list.
add-apt-repository "${GCC_PPA_URL}"
apt-get update

# Install a specific version of GCC.
apt-get install -y --no-install-recommends gcc-"${BUILD_TARGET_VERSION}" g++-"${BUILD_TARGET_VERSION}"

# Link standard CC and CXX to gcc.
ln -sf /usr/bin/gcc-"${BUILD_TARGET_VERSION}" /usr/bin/cc
ln -sf /usr/bin/g++-"${BUILD_TARGET_VERSION}" /usr/bin/c++
ln -sf /usr/bin/gcc-"${BUILD_TARGET_VERSION}" /usr/bin/gcc
ln -sf /usr/bin/g++-"${BUILD_TARGET_VERSION}" /usr/bin/g++
