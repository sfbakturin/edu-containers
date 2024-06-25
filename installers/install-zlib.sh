#!/bin/bash

git clone https://github.com/madler/zlib.git zlib-src/
cd zlib-src/ && CC=${COMPILER_NAME}-${COMPILER_VERSION} CXX=${COMPILER_NAMEXX}-${COMPILER_VERSION} ./configure --prefix=../zlib/
make && make install
cd .. && rm -rf zlib-src/
