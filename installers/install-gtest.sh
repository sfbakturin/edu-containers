#!/bin/bash

git clone https://github.com/google/googletest.git -b v1.14.0 gtest-src/
cd gtest-src/ && CC=${COMPILER_NAME}-${COMPILER_VERSION} CXX=${COMPILER_NAMEXX}-${COMPILER_VERSION} cmake . -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=../googletest
make && make install
cd .. && rm -rf gtest-src/
