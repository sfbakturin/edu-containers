FROM ubuntu:22.04

ARG COMPILER_NAME
ARG COMPILER_NAMEXX
ARG COMPILER_VERSION

# Update system.
RUN apt-get update && apt-get upgrade -y

# Install base utils.
COPY installers/install-base.sh .
RUN bash install-base.sh && rm install-base.sh

# Install C/C++ compiler.
COPY installers/install-${COMPILER_NAME}.sh .
RUN bash install-${COMPILER_NAME}.sh && rm install-${COMPILER_NAME}.sh

# Libraries.
WORKDIR /thirdparty

# Install zlib.
COPY installers/install-zlib.sh .
RUN bash install-zlib.sh && rm install-zlib.sh

# Install GoogleTest.
COPY installers/install-gtest.sh .
RUN bash install-gtest.sh && rm install-gtest.sh

# Install FFMPEG.
COPY installers/install-ffmpeg.sh .
RUN bash install-ffmpeg.sh && rm install-ffmpeg.sh

# Install FFTW.
COPY installers/install-fftw.sh .
RUN bash install-fftw.sh && rm install-fftw.sh

# Cleanup.
RUN apt-get autoremove -y --purge && apt-get autoclean

# Setup for student.
WORKDIR /student
