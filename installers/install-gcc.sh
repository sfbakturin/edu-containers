#!/bin/bash

add-apt-repository ppa:ubuntu-toolchain-r/test
apt-get update

apt-get install -y --no-install-recommends gcc-"${COMPILER_VERSION}" g++-"${COMPILER_VERSION}"

ln -sf /usr/bin/gcc-"${COMPILER_VERSION}" /usr/bin/cc
ln -sf /usr/bin/g++-"${COMPILER_VERSION}" /usr/bin/c++
