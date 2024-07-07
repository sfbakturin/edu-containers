#!/bin/bash

set -euo pipefail

FFTW_VERSION="3.3.10"

FFTW_URL="https://www.fftw.org"
FFTW_SRC="fftw-${FFTW_VERSION}"
FFTW_TAR="${FFTW_SRC}.tar.gz"

# Download and extract FFTW sources.
wget "${FFTW_URL}"/"${FFTW_TAR}"
tar -xf "${FFTW_TAR}"
rm "${FFTW_TAR}"

# Set working directory to FFTW sources.
pushd "${FFTW_SRC}"

# Build and install FFTW.
./configure --prefix="${EDU_FFTW}"
make -j"$(nproc --all)"
make install

# Go back.
popd

# Remove sources.
rm -rf "${FFTW_SRC}"
