#!/bin/bash

set -euo pipefail

FFMPEG_VERSION="release/6.1"

FFMPEG_URL="https://git.ffmpeg.org/ffmpeg.git"
FFMPEG_SRC="ffmpeg-src"

# Download FFMPEG sources.
git clone "${FFMPEG_URL}" -b "${FFMPEG_VERSION}" "${FFMPEG_SRC}"

# Set working directory to FFMPEG sources.
pushd "${FFMPEG_SRC}"

# Build, test and install FFMPEG.
./configure --cc="${COMPILER_NAME}-${COMPILER_VERSION}" --cxx="${COMPILER_NAMEXX}-${COMPILER_VERSION}" --disable-x86asm --prefix="${EDU_FFMPEG}"
make -j"$(nproc --all)"
make fate
make install

# Go back.
popd

# Remove sources.
rm -rf "${FFMPEG_SRC}"
