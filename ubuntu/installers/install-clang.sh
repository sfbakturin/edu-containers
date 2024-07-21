#!/usr/bin/env bash

set -euo pipefail

LLVM_APT_URL="https://apt.llvm.org"
LLVM_INSTALL_SCRIPT="llvm.sh"

# Remove GCC from specific packages of base.
apt-get remove --purge --autoremove -y gcc g++ gcc-11 g++-11

# Download automatic installation script.
wget "${LLVM_APT_URL}/${LLVM_INSTALL_SCRIPT}"

# Install a specific version of LLVM and remove script.
bash "${LLVM_INSTALL_SCRIPT}" "${BUILD_TARGET_VERSION}"
rm "${LLVM_INSTALL_SCRIPT}"

# Link standard CC and CXX to clang.
ln -s /usr/bin/clang-"${BUILD_TARGET_VERSION}" /usr/bin/cc
ln -s /usr/bin/clang++-"${BUILD_TARGET_VERSION}" /usr/bin/c++
