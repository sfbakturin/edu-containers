FROM ubuntu:22.04

ARG COMPILER_NAME
ARG COMPILER_NAMEXX
ARG COMPILER_VERSION

ENV EDU_THIRDPARTY=/thirdparty
ENV EDU_STUDENT=/student

# Update system.
RUN apt-get update && apt-get upgrade -y

# Install base utils.
COPY installers/install-base.sh .
RUN bash install-base.sh && rm install-base.sh

# Install C/C++ compiler.
COPY installers/install-${COMPILER_NAME}.sh .
RUN bash install-${COMPILER_NAME}.sh && rm install-${COMPILER_NAME}.sh

# Libraries.
WORKDIR ${EDU_THIRDPARTY}

# Install zlib.
ENV EDU_ZLIB=${EDU_THIRDPARTY}/zlib
ENV EDU_ZLIB_INCLUDE=${EDU_ZLIB}/include
ENV EDU_ZLIB_LIBRARY=${EDU_ZLIB}/lib

COPY installers/install-zlib.sh .
RUN bash install-zlib.sh && rm install-zlib.sh

# Install GoogleTest.
ENV EDU_GTEST=${EDU_THIRDPARTY}/googletest
ENV EDU_GTEST_INCLUDE=${EDU_GTEST}/include
ENV EDU_GTEST_LIBRARY=${EDU_GTEST}/lib

COPY installers/install-gtest.sh .
RUN bash install-gtest.sh && rm install-gtest.sh

# Install FFMPEG.
ENV EDU_FFMPEG=${EDU_THIRDPARTY}/ffmpeg
ENV EDU_FFMPEG_INCLUDE=${EDU_FFMPEG}/include
ENV EDU_FFMPEG_LIBRARY=${EDU_FFMPEG}/lib

COPY installers/install-ffmpeg.sh .
RUN bash install-ffmpeg.sh && rm install-ffmpeg.sh

# Install FFTW.
ENV EDU_FFTW=${EDU_THIRDPARTY}/fftw
ENV EDU_FFTW_INCLUDE=${EDU_FFTW}/include
ENV EDU_FFTW_LIBRARY=${EDU_FFTW}/lib

COPY installers/install-fftw.sh .
RUN bash install-fftw.sh && rm install-fftw.sh

# Cleanup.
RUN apt-get autoremove -y --purge && apt-get autoclean

# Student start-point.
WORKDIR ${EDU_STUDENT}
