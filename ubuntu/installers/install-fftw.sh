#!/usr/bin/env bash

set -euo pipefail

FFTW_VERSION='3.3.10'

FFTW_URL='https://www.fftw.org'
FFTW_SRC="fftw-${FFTW_VERSION}"
FFTW_TAR="${FFTW_SRC}.tar.gz"

BUILDDIR='BUILD'

# Download and extract FFTW sources.
wget "${FFTW_URL}"/"${FFTW_TAR}"
tar -xf "${FFTW_TAR}"
rm "${FFTW_TAR}"

# Set working directory to FFTW sources.
pushd "${FFTW_SRC}"

# Set working directory to temporary built sources.
mkdir "${BUILDDIR}"
pushd "${BUILDDIR}"

# Build FFTW (Single precision).
cmake .. -D CMAKE_INSTALL_PREFIX="${EDUCONTAINER_FFTW}" -D ENABLE_FLOAT=ON
make -j"$(nproc --all)"

# If BUILD_EXTRAS_RUN_TESTS == true, then we should test FFTW.
if $BUILD_EXTRAS_RUN_TESTS
then
  ## Test FFTW.
  ./bench --verify ib8192
  ./bench --speed ib8192
  ./bench --verify 512x1024
  ./bench --speed 512x1024
fi

# Install FFTW (Single precision).
make install

# Clean built.
rm -rf *

# Build FFTW (Double precision).
cmake .. -D CMAKE_INSTALL_PREFIX="${EDUCONTAINER_FFTW}" -D ENABLE_DOUBLE=ON
make -j"$(nproc --all)"

# If BUILD_EXTRAS_RUN_TESTS == true, then we should test FFTW.
if $BUILD_EXTRAS_RUN_TESTS
then
  ## Test FFTW.
  ./bench --verify ib8192
  ./bench --speed ib8192
  ./bench --verify 512x1024
  ./bench --speed 512x1024
fi

# Install FFTW (Double precision).
make install

# Go back.
popd
popd

# Remove sources.
rm -rf "${FFTW_SRC}"
