#!/bin/bash

git clone https://github.com/madler/zlib.git zlib-src/
cd zlib-src/ && ./configure --prefix=../zlib/
make && make install
cd .. && rm -rf zlib-src/
