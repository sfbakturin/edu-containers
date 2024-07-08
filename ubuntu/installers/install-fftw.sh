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

# Build FFTW.
./configure --prefix="${EDU_FFTW}"
make -j"$(nproc --all)"

# If RUN_TESTS == true, then we should test FFTW.
if $RUN_TESTS
then
  ## Set working directory to FFTW tests.
  pushd tests

  ## Test FFTW.
  ./bench --verify ib8192
  ./bench --speed ib8192
  ./bench --verify 512x1024
  ./bench --speed 512x1024

  ## Go back.
  popd
fi

# Install FFTW.
make install

# Go back.
popd

# Remove sources.
rm -rf "${FFTW_SRC}"
