# escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2022

ARG RUN_TESTS=false

ENV EDU_THIRDPARTY=/thirdparty
ENV EDU_STUDENT=/student

# ENV `
#     # Enable detection of running in a container
#     COMPLUS_RUNNING_IN_CONTAINER=1 `
#     COMPLUS_NGenProtectedProcess_FeatureEnabled=0

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

RUN `
    # Install Python 3.12.4
    curl -fSLo python-installer.exe https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe `
    && .\python-installer.exe /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 `
    && del .\python-installer.exe

RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
        --add Microsoft.VisualStudio.Workload.VCTools `
        --add Microsoft.VisualStudio.Component.VC.ASAN `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    && del /q vs_buildtools.exe

# RUN `
#     # Install Clang 18
#     curl -fSLo llvm-installer.exe https://github.com/llvm/llvm-project/releases/download/llvmorg-18.1.8/LLVM-18.1.8-win64.exe `
#     && .\llvm-installer.exe /S `
#     && del .\llvm-installer.exe `
#     && setx /M path "%PATH%;%ProgramFiles%\LLVM\bin;%ProgramFiles%\LLVM"

RUN `
    # Install CMake 3.29.6
    curl -fSLo cmake-installer.msi https://github.com/Kitware/CMake/releases/download/v3.29.6/cmake-3.29.6-windows-x86_64.msi `
    && msiexec /i cmake-installer.msi ALLUSERS=1 ADD_CMAKE_TO_PATH=System /qn `
    && del .\cmake-installer.msi

RUN `
    # Install 7-Zip 24.07
    curl -fSLo 7z-installer.msi https://www.7-zip.org/a/7z2407-x64.msi `
    && msiexec /i 7z-installer.msi /qn /norestart `
    && del .\7z-installer.msi `
    && setx /M path "%PATH%;%ProgramFiles%\7-Zip"

RUN `
    # Install ninja 1.12.1
    curl -fSLo ninja-installer.zip https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-win.zip `
    && mkdir "%ProgramFiles%\ninja" `
    && 7z x .\ninja-installer.zip -o"%ProgramFiles%\ninja" `
    && del .\ninja-installer.zip `
    && setx /M path "%PATH%;%ProgramFiles%\ninja"

RUN `
    # Install Git 2.45.2
    curl -fSLo git-installer.exe https://github.com/git-for-windows/git/releases/download/v2.45.2.windows.1/Git-2.45.2-64-bit.exe `
    && .\git-installer.exe /VERYSILENT /SUPPRESSMSGBOXES `
    && del .\git-installer.exe

# Libraries.
WORKDIR ${EDU_THIRDPARTY}

# Install GoogleTest.
ENV EDU_GOOGLETEST=${EDU_THIRDPARTY}/googletest
ENV EDU_GOOGLETEST_INCLUDE=${EDU_GOOGLETEST}/include
ENV EDU_GOOGLETEST_LIBRARY=${EDU_GOOGLETEST}/lib

RUN `
    "C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat" "-arch=amd64" `
    && git clone https://github.com/google/googletest.git -b v1.14.0 gtest-src `
    && pushd gtest-src `
    && cmake . -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=${EDU_GOOGLETEST} `
    && cmake --build . --target install --config Release `
    && popd `
    && rmdir gtest-src /S /Q
