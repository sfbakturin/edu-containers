#!/bin/bash

wget https://apt.llvm.org/llvm.sh

bash llvm.sh "${COMPILER_VERSION}"

rm llvm.sh

ln -sf /usr/bin/clang-"${COMPILER_VERSION}" /usr/bin/cc
ln -sf /usr/bin/clang++-"${COMPILER_VERSION}" /usr/bin/c++
