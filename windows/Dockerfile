FROM mcr.microsoft.com/windows/servercore:ltsc2019

ARG BUILD_TARGET_VERSION
ARG BUILD_EXTRAS_RUN_TESTS=false

ENV EDUCONTAINER_THIRDPARTY='C:/thirdparty'
ENV EDUCONTAINER_STUDENT='C:/student'
ENV EDUCONTAINER_TARGET_SYSTEM=windows
ENV EDUCONTAINER_TARGET_NAME=msvc

# Enable detection of running in a container
ENV COMPLUS_RUNNING_IN_CONTAINER=1
ENV COMPLUS_NGenProtectedProcess_FeatureEnabled=0

# Fixup msiexec.
RUN msiexec /REGISTER

# Set shell to powershell.
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install C/C++ compiler.
COPY windows/installers/install-msvc.ps1 .
RUN .\install-msvc.ps1; Remove-Item .\install-msvc.ps1

# Install CMake.
COPY windows/installers/install-cmake.ps1 .
RUN .\install-cmake.ps1; Remove-Item .\install-cmake.ps1

# Install Git.
COPY windows/installers/install-git.ps1 .
RUN .\install-git.ps1; Remove-Item .\install-git.ps1

# Install Python.
COPY windows/installers/install-python.ps1 .
RUN .\install-python.ps1; Remove-Item .\install-python.ps1

# Install Ninja.
COPY windows/installers/install-ninja.ps1 .
RUN .\install-ninja.ps1; Remove-Item .\install-ninja.ps1

# Libraries.
WORKDIR ${EDUCONTAINER_THIRDPARTY}

## Install zlib.
ENV EDUCONTAINER_ZLIB=${EDUCONTAINER_THIRDPARTY}/zlib
ENV EDUCONTAINER_ZLIB_INCLUDE=${EDUCONTAINER_ZLIB}/include
ENV EDUCONTAINER_ZLIB_LIBRARY=${EDUCONTAINER_ZLIB}/lib

COPY windows/installers/install-zlib.ps1 .
RUN .\install-zlib.ps1; Remove-Item .\install-zlib.ps1

## Install GoogleTest.
ENV EDUCONTAINER_GOOGLETEST=${EDUCONTAINER_THIRDPARTY}/googletest
ENV EDUCONTAINER_GOOGLETEST_INCLUDE=${EDUCONTAINER_GOOGLETEST}/include
ENV EDUCONTAINER_GOOGLETEST_LIBRARY=${EDUCONTAINER_GOOGLETEST}/lib

COPY windows/installers/install-gtest.ps1 .
RUN .\install-gtest.ps1; Remove-Item .\install-gtest.ps1

## Install FFmpeg.
ENV EDUCONTAINER_FFMPEG=${EDUCONTAINER_THIRDPARTY}/ffmpeg
ENV EDUCONTAINER_FFMPEG_INCLUDE=${EDUCONTAINER_FFMPEG}/include
ENV EDUCONTAINER_FFMPEG_LIBRARY=${EDUCONTAINER_FFMPEG}/lib

COPY windows/installers/install-ffmpeg.ps1 .
RUN .\install-ffmpeg.ps1; Remove-Item .\install-ffmpeg.ps1

## Install FFTW.
ENV EDUCONTAINER_FFTW=${EDUCONTAINER_THIRDPARTY}/fftw
ENV EDUCONTAINER_FFTW_INCLUDE=${EDUCONTAINER_FFTW}/include
ENV EDUCONTAINER_FFTW_LIBRARY=${EDUCONTAINER_FFTW}/lib

COPY windows/installers/install-fftw.ps1 .
RUN .\install-fftw.ps1; Remove-Item .\install-fftw.ps1

## Install libdeflate.
ENV EDUCONTAINER_LIBDEFLATE=${EDUCONTAINER_THIRDPARTY}/libdeflate
ENV EDUCONTAINER_LIBDEFLATE_INCLUDE=${EDUCONTAINER_LIBDEFLATE}/include
ENV EDUCONTAINER_LIBDEFLATE_LIBRARY=${EDUCONTAINER_LIBDEFLATE}/lib

COPY windows/installers/install-libdeflate.ps1 .
RUN .\install-libdeflate.ps1; Remove-Item .\install-libdeflate.ps1

# Student entry point.
WORKDIR ${EDUCONTAINER_STUDENT}

# Compiler file and default configs.
COPY compiler/ .

# Set Powershell as entrypoint.
ENTRYPOINT ["cmd.exe", "/K", "C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\VC\\Auxiliary\\Build\\vcvars64.bat"]
