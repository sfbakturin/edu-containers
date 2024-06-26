#!/bin/bash

git clone https://git.ffmpeg.org/ffmpeg.git -b release/6.1 ffmpeg-src
cd ffmpeg-src/ && ./configure --cc="${COMPILER_NAME}-${COMPILER_VERSION}" --cxx="${COMPILER_NAMEXX}-${COMPILER_VERSION}" --disable-x86asm --prefix=/thirdparty/ffmpeg/
make && make install
cd .. && rm -rf ffmpeg-src/
