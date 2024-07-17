# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019

ARG RUN_TESTS=false

ENV EDUCONTAINER_THIRDPARTY=/thirdparty
ENV EDUCONTAINER_STUDENT=/student

ENV `
    # Enable detection of running in a container
    COMPLUS_RUNNING_IN_CONTAINER=1 `
    COMPLUS_NGenProtectedProcess_FeatureEnabled=0

# RUN `
#     # Install .NET Fx 4.8
#     curl -fSLo dotnet-framework-installer.exe https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe `
#     && .\dotnet-framework-installer.exe /q `
#     && del .\dotnet-framework-installer.exe `
#     && powershell Remove-Item -Force -Recurse ${Env:TEMP}\* `
#     `
#     # Apply latest patch
#     && curl -fSLo patch.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2024/06/windows10.0-kb5039886-x64-ndp48_76b9d142a5868b40a8671860990c5c5d5d433548.msu `
#     && mkdir patch `
#     && expand patch.msu patch -F:* `
#     && del /F /Q patch.msu `
#     && dism /Online /Quiet /Add-Package /PackagePath:C:\patch\windows10.0-kb5039886-x64-ndp48.cab `
#     && rmdir /S /Q patch `
#     `
#     # ngen .NET Fx
#     && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen uninstall "Microsoft.Tpm.Commands, Version=10.0.0.0, Culture=Neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=amd64" `
#     && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen update `
#     && %windir%\Microsoft.NET\Framework\v4.0.30319\ngen update

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

# Install 7z.
COPY windows/installers/install-7z.ps1 .
RUN .\install-7z.ps1; Remove-Item .\install-7z.ps1

# Libraries.
WORKDIR ${EDUCONTAINER_THIRDPARTY}

ARG TARGET_BITS=64

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

## Install FFTW.
ENV EDUCONTAINER_FFTW=${EDUCONTAINER_THIRDPARTY}/fftw
ENV EDUCONTAINER_FFTW_INCLUDE=${EDUCONTAINER_FFTW}/include
ENV EDUCONTAINER_FFTW_LIBRARY=${EDUCONTAINER_FFTW}/lib

COPY windows/installers/install-fftw.ps1 .
RUN .\install-fftw.ps1; Remove-Item .\install-fftw.ps1
