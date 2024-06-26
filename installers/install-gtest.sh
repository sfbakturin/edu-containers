#!/bin/bash

git clone https://github.com/google/googletest.git -b v1.14.0 gtest-src/
cd gtest-src/ && cmake . -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/thirdparty/googletest
make && make install
cd .. && rm -rf gtest-src/
