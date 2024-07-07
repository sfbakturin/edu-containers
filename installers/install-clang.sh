#!/bin/bash

set -euo pipefail

LLVM_APT_URL="https://apt.llvm.org"
LLVM_INSTALL_SCRIPT="llvm.sh"

# Download automatic installation script.
wget "${LLVM_APT_URL}/${LLVM_INSTALL_SCRIPT}"

# Install a specific version of LLVM and remove script.
bash "${LLVM_INSTALL_SCRIPT}" "${COMPILER_VERSION}"
rm "${LLVM_INSTALL_SCRIPT}"

# Link standard CC and CXX to clang.
ln -sf /usr/bin/clang-"${COMPILER_VERSION}" /usr/bin/cc
ln -sf /usr/bin/clang++-"${COMPILER_VERSION}" /usr/bin/c++

# Remove GCC from specific packages of base.
apt-get remove --purge --autoremove -y gcc g++
