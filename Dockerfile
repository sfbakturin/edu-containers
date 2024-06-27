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
ENV EDU_GOOGLETEST=${EDU_THIRDPARTY}/googletest
ENV EDU_GOOGLETEST_INCLUDE=${EDU_GOOGLETEST}/include
ENV EDU_GOOGLETEST_LIBRARY=${EDU_GOOGLETEST}/lib

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

# Install libdeflate.
ENV EDU_LIBDEFLATE=${EDU_THIRDPARTY}/libdeflate
ENV EDU_LIBDEFLATE_INCLUDE=${EDU_LIBDEFLATE}/include
ENV EDU_LIBDEFLATE_LIBRARY=${EDU_LIBDEFLATE}/lib

COPY installers/install-libdeflate.sh .
RUN bash install-libdeflate.sh && rm install-libdeflate.sh

# Install isa-l.
ENV EDU_ISAL=${EDU_THIRDPARTY}/isal
ENV EDU_ISAL_INCLUDE=${EDU_ISAL}/include
ENV EDU_ISAL_LIBRARY=${EDU_ISAL}/lib

COPY installers/install-isal.sh .
RUN bash install-isal.sh && rm install-isal.sh

# Cleanup.
RUN apt-get autoremove -y --purge && apt-get autoclean

# Student start-point.
WORKDIR ${EDU_STUDENT}

# Compiler file and default configs.
COPY compile.py .
RUN chmod +x compile.py
COPY .compileconfig/ .compileconfig/
