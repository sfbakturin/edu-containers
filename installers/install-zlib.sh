#!/bin/bash

git clone https://github.com/madler/zlib.git zlib-src/
cd zlib-src/ && ./configure --prefix=/thirdparty/zlib/
make -j"$(nproc --all)" && make install
cd .. && rm -rf zlib-src/
