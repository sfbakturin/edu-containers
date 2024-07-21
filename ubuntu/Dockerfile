FROM ubuntu:22.04

ARG BUILD_TARGET_NAME
ARG BUILD_TARGET_NAMEXX
ARG BUILD_TARGET_VERSION
ARG BUILD_EXTRAS_RUN_TESTS=false

ENV EDUCONTAINER_THIRDPARTY=/thirdparty
ENV EDUCONTAINER_STUDENT=/student

# Update system.
RUN apt-get update && apt-get upgrade -y

# Install base utils.
COPY ubuntu/installers/install-base.sh .
RUN bash install-base.sh && rm install-base.sh

# Install python utils and libraries.
COPY ubuntu/installers/install-python.sh .
RUN bash install-python.sh && rm install-python.sh

# Install C/C++ compiler.
ENV CC=${BUILD_TARGET_NAME}-${BUILD_TARGET_VERSION}
ENV CXX=${BUILD_TARGET_NAMEXX}-${BUILD_TARGET_VERSION}

COPY ubuntu/installers/install-${BUILD_TARGET_NAME}.sh .
RUN bash install-${BUILD_TARGET_NAME}.sh && rm install-${BUILD_TARGET_NAME}.sh

# Libraries.
WORKDIR ${EDUCONTAINER_THIRDPARTY}

## Install zlib.
ENV EDUCONTAINER_ZLIB=${EDUCONTAINER_THIRDPARTY}/zlib
ENV EDUCONTAINER_ZLIB_INCLUDE=${EDUCONTAINER_ZLIB}/include
ENV EDUCONTAINER_ZLIB_LIBRARY=${EDUCONTAINER_ZLIB}/lib

COPY ubuntu/installers/install-zlib.sh .
RUN bash install-zlib.sh && rm install-zlib.sh

## Install GoogleTest.
ENV EDUCONTAINER_GOOGLETEST=${EDUCONTAINER_THIRDPARTY}/googletest
ENV EDUCONTAINER_GOOGLETEST_INCLUDE=${EDUCONTAINER_GOOGLETEST}/include
ENV EDUCONTAINER_GOOGLETEST_LIBRARY=${EDUCONTAINER_GOOGLETEST}/lib

COPY ubuntu/installers/install-gtest.sh .
RUN bash install-gtest.sh && rm install-gtest.sh

## Install FFMPEG.
ENV EDUCONTAINER_FFMPEG=${EDUCONTAINER_THIRDPARTY}/ffmpeg
ENV EDUCONTAINER_FFMPEG_INCLUDE=${EDUCONTAINER_FFMPEG}/include
ENV EDUCONTAINER_FFMPEG_LIBRARY=${EDUCONTAINER_FFMPEG}/lib

COPY ubuntu/installers/install-ffmpeg.sh .
RUN bash install-ffmpeg.sh && rm install-ffmpeg.sh

## Install FFTW.
ENV EDUCONTAINER_FFTW=${EDUCONTAINER_THIRDPARTY}/fftw
ENV EDUCONTAINER_FFTW_INCLUDE=${EDUCONTAINER_FFTW}/include
ENV EDUCONTAINER_FFTW_LIBRARY=${EDUCONTAINER_FFTW}/lib

COPY ubuntu/installers/install-fftw.sh .
RUN bash install-fftw.sh && rm install-fftw.sh

## Install libdeflate.
ENV EDUCONTAINER_LIBDEFLATE=${EDUCONTAINER_THIRDPARTY}/libdeflate
ENV EDUCONTAINER_LIBDEFLATE_INCLUDE=${EDUCONTAINER_LIBDEFLATE}/include
ENV EDUCONTAINER_LIBDEFLATE_LIBRARY=${EDUCONTAINER_LIBDEFLATE}/lib

COPY ubuntu/installers/install-libdeflate.sh .
RUN bash install-libdeflate.sh && rm install-libdeflate.sh

# Cleanup.
COPY ubuntu/installers/install-cleanup.sh .
RUN bash install-cleanup.sh && rm install-cleanup.sh

# Student entry point.
WORKDIR ${EDUCONTAINER_STUDENT}

# Compiler file and default configs.
COPY compiler/ .
RUN chmod +x compile.py
